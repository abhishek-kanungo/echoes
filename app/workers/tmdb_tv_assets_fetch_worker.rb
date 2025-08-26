# frozen_string_literal: true
class TmdbTvAssetsFetchWorker
  include Sidekiq::Worker
  sidekiq_options queue: :ingest, retry: 5

  def perform(event_id)
    event = Event.find(event_id)
    tmdb_id = event.metadata.dig("canonical_ids", "tmdb_tv_id") || event.external_id
    EchoesLogger.start("MEDIA_TV", "Fetching media for event", event_id: event.id, tmdb_id: tmdb_id)

    return unless tmdb_id && event.external_source == "tmdb_tv"

    client = Sources::Tmdb::Client.new
    images = client.tv_images(tmdb_id)
    videos = client.tv_videos(tmdb_id)

    repo = Catalog::MediaRepository.new
    posters   = (images["posters"]   || []).sort_by { |p| -p["vote_count"].to_i }.first(6)
    backdrops = (images["backdrops"] || []).sort_by { |b| -b["vote_count"].to_i }.first(6)
    EchoesLogger.log("MEDIA_TV", "Counts", posters: posters.size, backdrops: backdrops.size, videos: (videos["results"] || []).size)

    pos = 0
    posters.each do |p|
      attrs = Sources::Tmdb::AssetMapper.poster_to_asset(tmdb_id, p) # reuse mapper
      repo.upsert_and_link!(event: event, attrs: attrs, role: (pos.zero? ? "cover" : "poster"), position: pos)
      EchoesLogger.ok("MEDIA_TV_POSTER", "Linked poster", position: pos, preview: attrs[:preview_url])
      pos += 1
    end

    pos = 0
    backdrops.each do |b|
      attrs = Sources::Tmdb::AssetMapper.backdrop_to_asset(tmdb_id, b)
      repo.upsert_and_link!(event: event, attrs: attrs, role: "backdrop", position: pos)
      EchoesLogger.ok("MEDIA_TV_BACKDROP", "Linked backdrop", position: pos, preview: attrs[:preview_url])
      pos += 1
    end

    trailers = (videos["results"] || []).select { |v| v["type"] == "Trailer" }
    (trailers.presence || videos["results"] || []).first(3).each_with_index do |v, i|
      attrs = Sources::Tmdb::AssetMapper.video_to_asset(tmdb_id, v)
      next unless attrs
      repo.upsert_and_link!(event: event, attrs: attrs, role: "trailer", position: i)
      EchoesLogger.ok("MEDIA_TV_TRAILER", "Linked trailer", position: i, url: attrs[:url])
    end

    EchoesLogger.ok("MEDIA_TV", "Done", event_id: event.id)
  rescue => e
    EchoesLogger.fail("MEDIA_TV", "Error while fetching media", error: e.message, backtrace: e.backtrace&.first(5))
    raise
  end
end
