module Sources
  module Tmdb
    class Client
      BASE = "https://api.themoviedb.org/3"

      def initialize(token: ENV.fetch("TMDB_BEARER_TOKEN"))
        @http = HttpClient.new(
          base_url: BASE,
          headers: { "Authorization" => "Bearer \#{token}" }
        )
      end

      def discover_movies(year:, page: 1, vote_average_gte: 6.5, vote_count_gte: 1000, with_origin_country: nil, with_original_language: nil)
        params = {
          "primary_release_year" => year,
          "sort_by" => "popularity.desc",
          "vote_average.gte" => vote_average_gte,
          "vote_count.gte" => vote_count_gte,
          "page" => page
        }
        params["with_origin_country"] = with_origin_country if with_origin_country
        params["with_original_language"] = with_original_language if with_original_language
        @http.get("/discover/movie", params)
      end
    end
  end
end
