# frozen_string_literal: true
module Ingestion
  class TmdbTvSync
    def initialize(client:, logger:)
      @client = client
      @logger = logger
    end

    def call(discover_tv)
      tmdb_id = (discover_tv["id"] || discover_tv[:id]).to_i
      title   = discover_tv["name"] || discover_tv[:name] || discover_tv["original_name"] || "Untitled"
      @logger.log("SYNC_TV", "start", tmdb_id: tmdb_id, title: title)

      ev = Event.find_by(external_source: "tmdb_tv", external_id: tmdb_id)

      status =
        if ev.nil? || ENV.fetch("TMDB_SKIP_DETAILS_IF_EXISTS", "true") != "true"
          details = @client.tv_details(tmdb_id)
          ev = upsert_event!(discover_tv, details)
          :upserted
        else
          ev = upsert_minimal!(ev, discover_tv)
          :updated_minimal
        end

      if ENV.fetch("TMDB_FETCH_ASSETS_ON_UPSERT", "false") == "true" && status == :upserted && ev
        @logger.start("MEDIA_TV", "Fetching media for event", event_id: ev.id, tmdb_id: tmdb_id)
        begin
          # Reuse your movie asset worker with TV mapper? If you have TV-specific mapper, call that.
          # For now we’ll reuse the same worker; it uses poster/backdrop/video endpoints based on metadata.
          TmdbTvAssetsFetchWorker.new.perform(ev.id) # see worker below
          @logger.ok("MEDIA_TV", "Done", event_id: ev.id)
        rescue => e
          @logger.fail("MEDIA_TV_ERROR", "Error while fetching media", error: e.message, backtrace: e.backtrace&.first(5))
        end
      end

      @logger.ok("SYNC_TV", "upserted", tmdb_id: tmdb_id, event_id: ev&.id)
      [:upserted, ev]
    rescue => e
      @logger.fail("SYNC_TV_ERROR", "error", tmdb_id: tmdb_id, error: e.message)
      [:error, nil]
    end

    private

    def upsert_event!(disc, details)
      tmdb_id = disc["id"] || disc[:id]
      attrs = {
        external_source: "tmdb_tv",
        external_id: tmdb_id,
        title: details["name"] || disc["name"] || details["original_name"],
        description: details["overview"].presence || disc["overview"],
        cover_image_url: path_to_img(disc["poster_path"] || details["poster_path"]),
        popularity_score: details["popularity"] || disc["popularity"],
        source_url: "https://www.themoviedb.org/tv/#{tmdb_id}",
        event_date: details["first_air_date"] || disc["first_air_date"],
        metadata: {
          canonical_ids: { tmdb_tv_id: tmdb_id },
          discover: disc,
          details: details
        },
        visibility: "public",
        event_type: :tv
      }

      Event.where(external_source: "tmdb_tv", external_id: tmdb_id).first_or_initialize.tap do |ev|
        ev.assign_attributes(attrs)
        ev.save!
      end
    end

    def upsert_minimal!(ev, disc)
      ev.update!(
        title: ev.title.presence || disc["name"],
        cover_image_url: ev.cover_image_url.presence || path_to_img(disc["poster_path"]),
        popularity_score: disc["popularity"] || ev.popularity_score,
        event_date: ev.event_date.presence || disc["first_air_date"],
        metadata: (ev.metadata || {}).merge(discover: disc)
      )
      ev
    end

    def path_to_img(p)
      return nil if p.blank?
      "https://image.tmdb.org/t/p/w500#{p}"
    end
  end
end
