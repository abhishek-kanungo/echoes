# app/workers/tmdb_discover_coordinator_worker.rb
# frozen_string_literal: true

class TmdbDiscoverCoordinatorWorker
  include Sidekiq::Worker
  include IngestLogger

  sidekiq_options queue: :ingest, retry: 3

  def perform(year)
    started_at = Time.now
    ilog "start", year: year
    puts "[COORD] start year=#{year}"

    run = CrawlRun.find_or_create_by!(source: "tmdb", topic: "discover:movies", year: year)
    if run.total_pages.present? && run.current_page.to_i >= run.total_pages.to_i
      ilog "[CRAWL_OK] Already done", current_page: run.current_page, total_pages: run.total_pages
      run.update!(status: "done")
      ilog "done", elapsed: (Time.now - started_at).round(3)
      puts "[COORD] already_done current_page=#{run.current_page} total_pages=#{run.total_pages}"
      return
    end

    run.update!(status: "running") if run.status != "running"

    client = Sources::Tmdb::Client.new
    page = (run.current_page.present? ? run.current_page.to_i + 1 : 1)

    loop do
      ilog "[CRAWL_START] TMDb discover movies", year: year if page == 1
      ilog "[FETCH_PAGE] Requesting page", page: page
      puts "[COORD] fetch_page page=#{page}"

      resp = client.discover_movies(year: year, page: page)

      total_pages = (resp["total_pages"] || resp[:total_pages]).to_i
      results     = resp["results"] || resp[:results] || []
      ilog "[FETCH_PAGE_OK] Fetched page", page: page, total_pages: total_pages, count: results.size
      puts "[COORD] page_ok page=#{page} total_pages=#{total_pages} count=#{results.size}"

      run.update!(total_pages: total_pages) if run.total_pages.blank? || run.total_pages != total_pages

      results.each do |movie|
        tmdb_id = (movie["id"] || movie[:id]).to_i
        topic = "tmdb:discover:#{year}"
        if (ingest = create_ingest!("tmdb", movie, topic: topic))
          ilog "[ENQUEUED_INGEST]", tmdb_id: tmdb_id, topic: topic, ingest_id: ingest.id
          puts "[COORD] enqueued_ingest tmdb_id=#{tmdb_id} topic=#{topic} ingest_id=#{ingest.id}"
        else
          ilog "[DUP_INGEST_SKIP]", tmdb_id: tmdb_id, topic: topic
          puts "[COORD] dup_ingest_skip tmdb_id=#{tmdb_id} topic=#{topic}"
        end
      end

      run.update!(current_page: page, status: (page >= total_pages ? "done" : "running"))
      ilog "[PAGE_DONE_OK] Advanced run cursor", current_page: run.current_page, total_pages: run.total_pages
      puts "[COORD] page_done current_page=#{run.current_page} total_pages=#{run.total_pages}"

      break if page >= total_pages
      page += 1
    end

    ilog "done", elapsed: (Time.now - started_at).round(3)
    puts "[COORD] done elapsed=#{(Time.now - started_at).round(3)}s"
  rescue => e
    run&.update!(status: "error", last_error: "#{e.class}: #{e.message}")
    ilog "error", error: "#{e.class}: #{e.message}", backtrace: e.backtrace&.first(5)
    puts "[COORD] error class=#{e.class} message=#{e.message}"
    raise
  end

  private

  # Replaces your current create_ingest!
  def create_ingest!(source, raw, topic:)
    external_id = (raw["id"] || raw[:id]).to_s
    EchoesLogger.log("COORD", "create_ingest", source: source, external_id: external_id, topic: topic)
    puts "[COORD] create_ingest source=#{source} external_id=#{external_id} topic=#{topic}"

    ingest = Ingest.create!(
      source: source,
      external_id: external_id,
      topic: topic.to_s,
      payload: raw,
      status: "pending",
      error_message: nil
    )
    TmdbIngestProcessWorker.perform_async(ingest.id)
    EchoesLogger.ok("COORD", "ingest_created_enqueued", ingest_id: ingest.id)
    puts "[COORD] ingest_created_enqueued ingest_id=#{ingest.id}"
    ingest
  rescue ActiveRecord::RecordNotUnique
    # ← This is the important part: do NOT skip. Re‑enqueue the existing row.
    existing = Ingest.find_by(source: source, external_id: external_id, topic: topic.to_s)
    if existing
      existing.update!(status: "pending", error_message: nil, payload: existing.payload.presence || raw)
      TmdbIngestProcessWorker.perform_async(existing.id)
      EchoesLogger.log("COORD", "ingest_duplicate_reenqueued", ingest_id: existing.id)
      puts "[COORD] ingest_duplicate_reenqueued ingest_id=#{existing.id}"
      existing
    else
      EchoesLogger.log("COORD", "ingest_duplicate_skip_missing_lookup", source: source, external_id: external_id, topic: topic)
      puts "[COORD] ingest_duplicate_skip_missing_lookup external_id=#{external_id} topic=#{topic}"
      nil
    end
  end
end