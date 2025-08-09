class TmdbDiscoverFetchWorker
  include Sidekiq::Worker
  sidekiq_options queue: :ingest, retry: 5

  def perform(year, pages = 2, with_origin_country = nil, with_original_language = nil)
    client = Sources::Tmdb::Client.new
    1.upto(pages) do |page|
      res = client.discover_movies(
        year: year,
        page: page,
        with_origin_country: with_origin_country,
        with_original_language: with_original_language
      )
      (res["results"] || []).each do |raw|
        create_ingest!("tmdb", raw, topic: "tmdb:discover:\#{year}")
      end
      sleep 0.25
    end
  end

  private
  def create_ingest!(source, raw, topic:)
    key = Digest::SHA256.hexdigest("\#{source}|\#{raw["id"]}|\#{topic}|\#{raw.hash}")
    ingest = Ingest.create!(
      source: source,
      external_id: raw["id"].to_s,
      topic: topic,
      payload: raw,
      status: "pending",
      error_message: nil
    )
    TmdbIngestProcessWorker.perform_async(ingest.id)
  rescue ActiveRecord::RecordNotUnique
    # ignore if duplicate
  end
end
