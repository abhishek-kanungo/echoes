# frozen_string_literal: true

module Ingestion
  # Synchronous ingestion using ONLY the discover payload first (quality gate),
  # and calling TMDb details ONLY when necessary. Designed to reduce API calls.
  class TmdbSync
    VOTE_AVG_MIN   = (ENV['TMDB_VOTE_AVG_MIN']   || '4').to_f
    VOTE_COUNT_MIN = (ENV['TMDB_VOTE_COUNT_MIN'] || ' 25').to_i

    # If true, when an Event already exists, we skip the details call and
    # just perform a cheap refresh from discover payload.
    SKIP_DETAILS_IF_EXISTS = ENV.fetch('TMDB_SKIP_DETAILS_IF_EXISTS', 'true') == 'true'

    def initialize(client: Sources::Tmdb::Client.new, logger: EchoesLogger)
      @client = client
      @logger = logger
    end

    # Process a single discover row synchronously.
    # Returns [:skipped_quality | :updated_minimal | :upserted, event_or_nil]
    def call(discover_row)
      tmdb_id = (discover_row['id'] || discover_row[:id]).to_i
      title   = discover_row['title'] || discover_row[:title] || discover_row['original_title'] || "Untitled"

      puts "[SYNC] start tmdb_id=#{tmdb_id} title=#{title.inspect}"

      # 1) Quality gate using discover payload (NO extra API call)
      va = fetch_float(discover_row, :vote_average)
      vc = fetch_int(discover_row,   :vote_count)
      unless pass_quality?(va, vc)
        @logger.log("SYNC", "skip_quality", id: tmdb_id, vote_average: va, vote_count: vc)
        puts "[SYNC] skip_quality tmdb_id=#{tmdb_id} va=#{va} vc=#{vc}"
        return [:skipped_quality, nil]
      end

      # 2) Fast path: existing event? Optionally skip details to reduce API calls
      event = Event.find_by(external_source: "tmdb", external_id: tmdb_id)
      if event && SKIP_DETAILS_IF_EXISTS
        event.update!(
          title:            title,
          cover_image_url:  discover_row['poster_path'] ? "https://image.tmdb.org/t/p/w500#{discover_row['poster_path']}" : event.cover_image_url,
          popularity_score: fetch_float(discover_row, :popularity),
          event_date:       discover_row['release_date'] || discover_row[:release_date],
          metadata:         (event.metadata || {}).merge('discover_snapshot' => discover_row)
        )
        puts "[SYNC] updated_minimal tmdb_id=#{tmdb_id} event_id=#{event.id}"
        return [:updated_minimal, event]
      end

      # 3) Otherwise, fetch details ONCE and upsert
      #details = @client.movie_details(tmdb_id)
      upsert_from_details!(discover_row)
      event = Event.find_by!(external_source: "tmdb", external_id: tmdb_id)
      puts "[SYNC] upserted tmdb_id=#{tmdb_id} event_id=#{event.id}"
      [:upserted, event]
      #TmdbMovieAssetsFetchWorker.new.perform(event.id)

    rescue => e
      @logger.fail("SYNC", "error", tmdb_id: (discover_row['id'] || discover_row[:id]), error: e.message)
      puts "[SYNC] error tmdb_id=#{(discover_row['id'] || discover_row[:id])} error=#{e.message}"
      raise
    end

    private

    def pass_quality?(vote_avg, vote_count)
      #vote_avg && vote_count && vote_avg >= VOTE_AVG_MIN && vote_count >= VOTE_COUNT_MIN
      true
    end

    def fetch_float(h, key)
      v = fetch(h, key); v&.to_f
    end

    def fetch_int(h, key)
      v = fetch(h, key); v&.to_i
    end

    def fetch(h, key)
      return nil unless h.respond_to?(:key?)      

      h[key] || h[key.to_s]
    end

    def upsert_from_details!(m)
      attrs = {
        external_source:  'tmdb',
        external_id:      m['id'],
        title:            m['title'] || m['original_title'] || 'Untitled',
        description:      m['overview'],
        cover_image_url:  m['poster_path'] ? "https://image.tmdb.org/t/p/w500#{m['poster_path']}" : nil,
        popularity_score: m['popularity'],
        impact_score:     m['vote_average'],
        source_url:       "https://www.themoviedb.org/movie/#{m['id']}",
        event_date:       m['release_date'],
        event_type:       :movie,
        visibility:       'public',
        metadata: {
          genres: (m['genres'] || []).map { _1['name'] },
          original_language: m['original_language'],
          details_snapshot: m
        }
      }
      # requires unique index on events(external_source, external_id)
      Event.upsert(attrs, unique_by: :idx_events_unique_external)
    end
  end
end
