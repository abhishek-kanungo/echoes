# app/workers/tmdb_discover_fetch_worker.rb
class TmdbDiscoverFetchWorker
  include Sidekiq::Worker
  sidekiq_options queue: :ingest, retry: 5

  def perform(year, pages = 2, with_origin_country = nil, with_original_language = nil)
    client = Sources::Tmdb::Client.new
    puts "[FETCH] start year=#{year} pages=#{pages} country=#{with_origin_country} lang=#{with_original_language}"
    1.upto(pages) do |page|
      res = client.discover_movies(
        year: year,
        page: page,
        with_origin_country: with_origin_country,
        with_original_language: with_original_language
      )
      results = (res["results"] || [])
      puts "[FETCH] page_ok page=#{page} count=#{results.size}"
      results.each do |raw|
        # Ensure topic interpolation (no backslash escaping)
        create_ingest!("tmdb", raw, topic: "tmdb:discover:#{year}")
      end
      sleep 0.25
    end
    puts "[FETCH] done year=#{year}"
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