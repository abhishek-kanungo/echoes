module Sources
  module Tmdb
    class AssetMapper
      IMG_BASE = "https://image.tmdb.org/t/p"
      # sizes: w92, w154, w185, w342, w500, w780, original

      def self.poster_to_asset(movie_id, poster)
        {
          provider: "tmdb",
          external_id: poster["file_path"],
          media_type: "image",
          subtype: "poster",
          url: "#{IMG_BASE}/original#{poster["file_path"]}",
          preview_url: "#{IMG_BASE}/w342#{poster["file_path"]}",
          mime: "image/jpeg",
          width: poster["width"], height: poster["height"],
          aspect_ratio: safe_aspect(poster),
          language: poster["iso_639_1"],
          vote_count: poster["vote_count"], vote_average: poster["vote_average"],
          metadata: { tmdb_movie_id: movie_id }
        }
      end

      def self.backdrop_to_asset(movie_id, backdrop)
        {
          provider: "tmdb",
          external_id: backdrop["file_path"],
          media_type: "image",
          subtype: "backdrop",
          url: "#{IMG_BASE}/original#{backdrop["file_path"]}",
          preview_url: "#{IMG_BASE}/w780#{backdrop["file_path"]}",
          mime: "image/jpeg",
          width: backdrop["width"], height: backdrop["height"],
          aspect_ratio: safe_aspect(backdrop),
          language: backdrop["iso_639_1"],
          vote_count: backdrop["vote_count"], vote_average: backdrop["vote_average"],
          metadata: { tmdb_movie_id: movie_id }
        }
      end

      def self.video_to_asset(movie_id, video)
        return nil unless video["site"] == "YouTube"
        key = video["key"]
        {
          provider: "youtube",
          external_id: key,
          media_type: "video",
          subtype: (video["type"]&.downcase || "trailer"),
          url: "https://www.youtube.com/watch?v=#{key}",
          preview_url: "https://img.youtube.com/vi/#{key}/hqdefault.jpg",
          mime: "text/html",
          width: nil, height: nil, aspect_ratio: 16.0/9,
          language: video["iso_639_1"],
          vote_count: nil, vote_average: nil,
          metadata: { tmdb_movie_id: movie_id, official: video["official"], published_at: video["published_at"] }
        }
      end

      def self.safe_aspect(h)
        w = h["width"].to_f
        hgt = h["height"].to_f
        return nil if w <= 0 || hgt <= 0
        (w / hgt).round(4)
      rescue
        nil
      end
    end
  end
end
