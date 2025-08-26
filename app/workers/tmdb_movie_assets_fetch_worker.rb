class TmdbMovieAssetsFetchWorker
  include Sidekiq::Worker
  sidekiq_options queue: :ingest, retry: 5

  def perform(event_id)
    event = Event.find(event_id)
    tmdb_id = event.metadata.dig("canonical_ids", "tmdb_id") || event.external_id
    EchoesLogger.start("MEDIA", "Fetching media for event", event_id: event.id, tmdb_id: tmdb_id)

    return unless tmdb_id && event.external_source == "tmdb"

    client = Sources::Tmdb::Client.new
    images = client.movie_images(tmdb_id)
    videos = client.movie_videos(tmdb_id)

    repo = Catalog::MediaRepository.new
    posters = (images["posters"] || []).sort_by { |p| -p["vote_count"].to_i }.first(6)
    backdrops = (images["backdrops"] || []).sort_by { |b| -b["vote_count"].to_i }.first(6)
    EchoesLogger.log("MEDIA", "Counts", posters: posters.size, backdrops: backdrops.size, videos: (videos["results"] || []).size)

    pos = 0
    posters.each do |p|
      attrs = Sources::Tmdb::AssetMapper.poster_to_asset(tmdb_id, p)
      repo.upsert_and_link!(event: event, attrs: attrs, role: (pos.zero? ? "cover" : "poster"), position: pos)
      EchoesLogger.ok("MEDIA_POSTER", "Linked poster", position: pos, preview: attrs[:preview_url])
      pos += 1
    end

    pos = 0
    backdrops.each do |b|
      attrs = Sources::Tmdb::AssetMapper.backdrop_to_asset(tmdb_id, b)
      repo.upsert_and_link!(event: event, attrs: attrs, role: "backdrop", position: pos)
      EchoesLogger.ok("MEDIA_BACKDROP", "Linked backdrop", position: pos, preview: attrs[:preview_url])
      pos += 1
    end

    trailers = (videos["results"] || []).select { |v| v["type"] == "Trailer" }
    (trailers.presence || videos["results"] || []).first(3).each_with_index do |v, i|
      attrs = Sources::Tmdb::AssetMapper.video_to_asset(tmdb_id, v)
      next unless attrs
      repo.upsert_and_link!(event: event, attrs: attrs, role: "trailer", position: i)
      EchoesLogger.ok("MEDIA_TRAILER", "Linked trailer", position: i, url: attrs[:url])
    end

    EchoesLogger.ok("MEDIA", "Done", event_id: event.id)
  rescue => e
    EchoesLogger.fail("MEDIA", "Error while fetching media", error: e.message, backtrace: e.backtrace&.first(5))
    raise
  end
end
