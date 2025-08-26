# frozen_string_literal: true
class TmdbTvDiscoverShardedCoordinatorWorker
  include Sidekiq::Worker
  include IngestLogger
  sidekiq_options queue: :ingest, retry: 3

  PAGE_CAP = 500

  def perform(year)
    @year   = year.to_i
    @client = Sources::Tmdb::Client.new
    @sync   = Ingestion::TmdbTvSync.new(client: @client, logger: EchoesLogger)

    from = Date.new(@year, 1, 1)
    to   = Date.new(@year, 12, 31)

    ilog "start_tv_sharded", year: @year
    puts "[COORD_TV_SHARD] start year=#{@year} window=#{from}..#{to}"

    crawl_window(from, to, depth: 0)

    ilog "done_tv", year: @year
    puts "[COORD_TV_SHARD] done year=#{@year}"
  rescue => e
    ilog "error_tv", error: "#{e.class}: #{e.message}", backtrace: e.backtrace&.first(5)
    puts "[COORD_TV_SHARD] fatal error class=#{e.class} message=#{e.message}"
    raise
  end

  private

  def crawl_window(from_date, to_date, depth:)
    params = {
      year: @year,
      first_air_date_gte: from_date.to_s,
      first_air_date_lte: to_date.to_s,
      include_adult: false,
      sort_by: "popularity.desc",
      page: 1
    }

    puts "[COORD_TV_SHARD] probe depth=#{depth} #{from_date}..#{to_date}"
    resp = safe_discover(params)
    total_pages = (resp["total_pages"] || resp[:total_pages]).to_i
    first_count = (resp["results"] || resp[:results] || []).size
    puts "[COORD_TV_SHARD] window_stats depth=#{depth} pages=#{total_pages} first_count=#{first_count}"

    if total_pages < PAGE_CAP
      1.upto(total_pages) do |page|
        r = safe_discover(params.merge(page: page))
        results = r["results"] || r[:results] || []
        puts "[COORD_TV_SHARD] fetch page=#{page}/#{total_pages} window=#{from_date}..#{to_date} count=#{results.size}"

        results.each do |tv|
          tmdb_id = (tv["id"] || tv[:id]).to_i
          begin
            status, ev = @sync.call(tv)
            puts "[COORD_TV_SHARD] ingested tmdb_tv_id=#{tmdb_id} status=#{status} event_id=#{ev&.id}"
          rescue => e
            puts "[COORD_TV_SHARD] error tmdb_tv_id=#{tmdb_id} err=#{e.message}"
          end
        end
      end
    else
      mid = from_date + ((to_date - from_date) / 2)
      left_end   = [mid, to_date].min
      right_from = (left_end + 1)

      if left_end < from_date || right_from > to_date
        puts "[COORD_TV_SHARD] degenerate window; running capped crawl #{from_date}..#{to_date}"
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
      first_air_date_gte: from_date.to_s,
      first_air_date_lte: to_date.to_s,
      include_adult: false,
      sort_by: "popularity.desc"
    }
    1.upto(PAGE_CAP) do |page|
      r = safe_discover(params.merge(page: page))
      results = r["results"] || []
      break if results.empty?

      puts "[COORD_TV_SHARD] capped_fetch page=#{page}/#{PAGE_CAP} window=#{from_date}..#{to_date} count=#{results.size}"
      results.each do |tv|
        tmdb_id = (tv["id"] || tv[:id]).to_i
        begin
          status, ev = @sync.call(tv)
          puts "[COORD_TV_SHARD] ingested tmdb_tv_id=#{tmdb_id} status=#{status} event_id=#{ev&.id}"
        rescue => e
          puts "[COORD_TV_SHARD] error tmdb_tv_id=#{tmdb_id} err=#{e.message}"
        end
      end
    end
  end

  def safe_discover(params)
    p = params[:page]
    params = params.merge(page: p ? p.to_i.clamp(1, PAGE_CAP) : 1)
    # Map our TV sharding params to client keywords
    @client.discover_tv(
      year: params[:year],
      page: params[:page],
      first_air_date_gte: params[:first_air_date_gte],
      first_air_date_lte: params[:first_air_date_lte],
      include_adult: params[:include_adult],
      sort_by: params[:sort_by]
    )
  rescue => e
    puts "[COORD_TV_SHARD] discover_error params=#{params.inspect} error=#{e.message}"
    raise
  end
end
