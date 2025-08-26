# frozen_string_literal: true
require "date"

module Sources
  module Tmdb
    class Mapper
      class << self
        def to_mapped_event(raw)
          {
            external_source: "tmdb",
            external_id: raw["id"].to_s,
            event_type: :movie,
            title: raw["title"] || raw["name"],
            description: raw["overview"],
            event_date: parse_date(raw["release_date"]),
            cover_image_url: raw["poster_path"] ? "https://image.tmdb.org/t/p/w500#{raw["poster_path"]}" : nil,
            source_url: raw["id"] ? "https://www.themoviedb.org/movie/#{raw["id"]}" : nil,
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

        def normalize_popularity(raw)
          p = raw["popularity"].to_f        # TMDb "popularity" ~ 0..1000+
          v = raw["vote_count"].to_i
          score  = [p / 1000.0, 1.0].min    # squash to 0..1
          factor = [[v / 100.0, 0.1].max, 1.0].min # downweight tiny vote counts
          (score * factor).round(4)
        end

        def parse_date(str)
          return nil if str.to_s.strip.empty?
          Date.parse(str) rescue nil
        end
      end
    end
  end
end
