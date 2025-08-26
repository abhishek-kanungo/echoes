# frozen_string_literal: true
class TmdbDiscoverShardedCoordinatorWorker
  include Sidekiq::Worker
  include IngestLogger

  sidekiq_options queue: :ingest, retry: 3
  PAGE_CAP = 500

  def perform(year)
    @year   = year.to_i
    @client = Sources::Tmdb::Client.new
    @sync   = Ingestion::TmdbSync.new(client: @client, logger: EchoesLogger)

    from = Date.new(@year, 1, 1)
    to   = Date.new(@year, 12, 31)

    ilog "start_sharded", year: @year
    puts "[COORD_SHARD] start year=#{@year} window=#{from}..#{to}"

    crawl_window(from, to, depth: 0)

    ilog "done", year: @year
    puts "[COORD_SHARD] done year=#{@year}"
  rescue => e
    ilog "error", error: "#{e.class}: #{e.message}", backtrace: e.backtrace&.first(5)
    puts "[COORD_SHARD] fatal error class=#{e.class} message=#{e.message}"
    raise
  end

  private

  def crawl_window(from_date, to_date, depth:)
    params = {
      year: @year,
      primary_release_date_gte: from_date.to_s,
      primary_release_date_lte: to_date.to_s,
      include_adult: false,
      sort_by: "popularity.desc",
      page: 1
    }

    puts "[COORD_SHARD] probe depth=#{depth} #{from_date}..#{to_date}"
    resp = safe_discover(params)
    total_pages = (resp["total_pages"] || resp[:total_pages]).to_i
    first_count = (resp["results"] || resp[:results] || []).size
    puts "[COORD_SHARD] window_stats depth=#{depth} pages=#{total_pages} first_count=#{first_count}"

    if total_pages < PAGE_CAP
      1.upto(total_pages) do |page|
        r = safe_discover(params.merge(page: page))
        results = r["results"] || r[:results] || []
        puts "[COORD_SHARD] fetch page=#{page}/#{total_pages} window=#{from_date}..#{to_date} count=#{results.size}"

        results.each do |movie|
          tmdb_id = (movie["id"] || movie[:id]).to_i
          begin
            status, ev = @sync.call(movie) # synchronous ingestion
            puts "[COORD_SHARD] ingested tmdb_id=#{tmdb_id} status=#{status} event_id=#{ev&.id}"
          rescue => e
            puts "[COORD_SHARD] error tmdb_id=#{tmdb_id} err=#{e.message}"
          end
        end
      end
    else
      mid = from_date + ((to_date - from_date) / 2)
      left_end   = [mid, to_date].min
      right_from = (left_end + 1)

      if left_end < from_date || right_from > to_date
        puts "[COORD_SHARD] degenerate window; running capped crawl #{from_date}..#{to_date}"
        crawl_capped(from_date, to_date)
        return
      end

      crawl_window(from_date, left_end, depth: depth + 1)
      crawl_window(right_from, to_date, depth: depth + 1)
    end
  end

  def crawl_capped(from_date, to_date)
    params = {
      year: @year,
      primary_release_date_gte: from_date.to_s,
      primary_release_date_lte: to_date.to_s,
      include_adult: false,
      sort_by: "popularity.desc"
    }

    1.upto(PAGE_CAP) do |page|
      r = safe_discover(params.merge(page: page))
      results = r["results"] || []
      break if results.empty?

      puts "[COORD_SHARD] capped_fetch page=#{page}/#{PAGE_CAP} window=#{from_date}..#{to_date} count=#{results.size}"
      results.each do |movie|
        tmdb_id = (movie["id"] || movie[:id]).to_i
        begin
          status, ev = @sync.call(movie)
          puts "[COORD_SHARD] ingested tmdb_id=#{tmdb_id} status=#{status} event_id=#{ev&.id}"
        rescue => e
          puts "[COORD_SHARD] error tmdb_id=#{tmdb_id} err=#{e.message}"
        end
      end
    end
  end

  def safe_discover(params)
    # Sanity: clamp page 1..500 before hitting API
    p = params[:page]
    params = params.merge(page: p ? p.to_i.clamp(1, PAGE_CAP) : 1)
    @client.discover_movies(**params)
  rescue => e
    puts "[COORD_SHARD] discover_error params=#{params.inspect} error=#{e.message}"
    raise
  end
end
