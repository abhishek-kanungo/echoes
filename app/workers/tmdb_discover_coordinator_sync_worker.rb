# frozen_string_literal: true

class TmdbDiscoverCoordinatorSyncWorker
  include Sidekiq::Worker
  include IngestLogger

  # Runs in Sidekiq but processes each movie synchronously to reduce API calls.
  sidekiq_options queue: :ingest, retry: 3

  def perform(year)
    started_at = Time.now
    ilog "start_sync", year: year
    puts "[COORD_SYNC] start year=#{year}"

    run = CrawlRun.find_or_create_by!(source: "tmdb", topic: "discover:movies", year: year)
    if run.total_pages.present? && run.current_page.to_i >= run.total_pages.to_i
      ilog "[CRAWL_OK] Already done", current_page: run.current_page, total_pages: run.total_pages
      run.update!(status: "done")
      ilog "done", elapsed: (Time.now - started_at).round(3)
      puts "[COORD_SYNC] already_done current_page=#{run.current_page} total_pages=#{run.total_pages}"
      return
    end

    run.update!(status: "running") if run.status != "running"

    client = Sources::Tmdb::Client.new
    sync   = Ingestion::TmdbSync.new(client: client, logger: EchoesLogger)

    page = (run.current_page.present? ? run.current_page.to_i + 1 : 1)

    loop do
      ilog "[CRAWL_START] TMDb discover movies (sync)", year: year if page == 1
      ilog "[FETCH_PAGE] Requesting page", page: page
      puts "[COORD_SYNC] fetch_page page=#{page}"

      resp = client.discover_movies(year: year, page: page)
      total_pages = (resp["total_pages"] || resp[:total_pages]).to_i
      results     = resp["results"] || resp[:results] || []
      ilog "[FETCH_PAGE_OK] Fetched page", page: page, total_pages: total_pages, count: results.size
      puts "[COORD_SYNC] page_ok page=#{page} total_pages=#{total_pages} count=#{results.size}"

      run.update!(total_pages: total_pages) if run.total_pages.blank? || run.total_pages != total_pages

      results.each do |movie|
        tmdb_id = (movie["id"] || movie[:id]).to_i
        begin
          status, ev = sync.call(movie) # ← synchronous ingestion per discovery
          ilog "[SYNC_STATUS]", tmdb_id: tmdb_id, status: status
          puts "[COORD_SYNC] sync_status=#{status} tmdb_id=#{tmdb_id} event_id=#{ev&.id}"

          # Optional: fetch assets only for full upserts to keep API calls low
          if status == :upserted && ev
            TmdbMovieAssetsFetchWorker.new.perform(ev.id)
          end
        rescue => e
          ilog "error_item", tmdb_id: tmdb_id, error: e.message
          puts "[COORD_SYNC] error_item tmdb_id=#{tmdb_id} error=#{e.message}"
        end
      end

      run.update!(current_page: page, status: (page >= total_pages ? "done" : "running"))
      ilog "[PAGE_DONE_OK] Advanced run cursor", current_page: run.current_page, total_pages: run.total_pages
      puts "[COORD_SYNC] page_done current_page=#{run.current_page} total_pages=#{run.total_pages}"

      break if page >= total_pages
      page += 1
    end

    ilog "done", elapsed: (Time.now - started_at).round(3)
    puts "[COORD_SYNC] done elapsed=#{(Time.now - started_at).round(3)}s"
  rescue => e
    run&.update!(status: "error", last_error: "#{e.class}: #{e.message}")
    ilog "error", error: "#{e.class}: #{e.message}", backtrace: e.backtrace&.first(5)
    puts "[COORD_SYNC] error class=#{e.class} message=#{e.message}"
    raise
  end
end
