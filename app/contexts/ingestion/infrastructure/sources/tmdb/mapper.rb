module Sources
  module Tmdb
    class Mapper
      # raw => mapped DTO Hash in our ubiquitous language
      def self.to_mapped_event(raw)
        {
          external_source: "tmdb",
          external_id: raw["id"].to_s,
          event_type: :movie,
          title: raw["title"],
          description: raw["overview"],
          event_date: (Date.parse(raw["release_date"]) rescue nil),
          cover_image_url: raw["poster_path"] ? "https://image.tmdb.org/t/p/w500\#{raw["poster_path"]}" : nil,
          source_url: "https://www.themoviedb.org/movie/\#{raw["id"]}",
          popularity_score: normalize_popularity(raw),
          impact_score: nil,
          confidence: 0.9,
          metadata: {
            genres: (raw["genre_ids"] || []),
            language: raw["original_language"],
            quality_signals: {
              vote_average: raw["vote_average"],
              vote_count: raw["vote_count"]
            },
            canonical_ids: { tmdb_id: raw["id"] }
          }
        }
      end

      def self.normalize_popularity(raw)
        va = raw["vote_average"].to_f
        vc = raw["vote_count"].to_i
        return 0.0 if vc <= 0
        (va * Math.log(vc + 1)).round(4)
      end
    end
  end
end
