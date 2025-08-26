# frozen_string_literal: true
module Sources
  module Tmdb
    class Client
               TMDB_HOST = "https://api.themoviedb.org/3"    


      def initialize(api_key: ENV["TMDB_API_KEY"])
        @api_key = Rails.application.credentials.dig(:tmdb, :api_key)
        @bearer_token = Rails.application.credentials.dig(:tmdb, :bearer_token)  
      end
      
      def discover_movies(year:, page: 1, **opts)
        uri = URI("#{TMDB_HOST}/discover/movie")

      
        params = {
          page: page.to_i,                          # TMDb expects integer, >=1
          primary_release_year: year.to_i           # TMDb discover accepts this
        }

        # Map friendly ruby keys to TMDb query param names.
        # Only add if provided, to avoid sending nils.
        map_bool!(params, "include_adult", opts[:include_adult])
        map_bool!(params, "include_video", opts[:include_video])

        map_str!(params, "sort_by", opts[:sort_by]) # e.g. "popularity.desc"

        # Date windows for sharding around the 500-page cap
        map_str!(params, "primary_release_date.gte", opts[:primary_release_date_gte])
        map_str!(params, "primary_release_date.lte", opts[:primary_release_date_lte])

        # Optional language/country filters
        map_str!(params, "with_original_language", opts[:with_original_language])
        map_str!(params, "with_origin_country",   opts[:with_origin_country])

        # Optional quality gates (to reduce result set)
        map_num!(params, "vote_average.gte", opts[:vote_average_gte])
        map_num!(params, "vote_count.gte",   opts[:vote_count_gte])
        map_num!(params, "vote_average.lte", opts[:vote_average_lte])
        map_num!(params, "vote_count.lte",   opts[:vote_count_lte])

        # Any additional raw TMDb params you want to forward directly:
        #   opts[:raw] can be a hash of already-TMDb-shaped params
        if opts[:raw].is_a?(Hash)
          opts[:raw].each { |k, v| params[k.to_s] = v }
        end

        uri.query = URI.encode_www_form(params)

        json = get_json(uri)
        {
          total_pages: json["total_pages"] || 1,
          results: json["results"] || []
        }.with_indifferent_access      
      end
      
      def discover_tv(year:, page: 1, **opts)
        uri = URI("#{TMDB_HOST}/discover/tv")
        params = {
          page: page,
          sort_by: "popularity.desc",
          "first_air_date_year" => year
        }.compact

        uri.query = URI.encode_www_form(params)
        
        json = get_json(uri)
        {
          total_pages: json["total_pages"] || 1,
          results: json["results"] || []
        }.with_indifferent_access
      end

      def tv_details(id)
        uri = URI("#{TMDB_HOST}/tv/#{id}")
        uri.query = URI.encode_www_form({})
        get_json(uri).with_indifferent_access
      end
alias_method :tv, :tv_details

def tv_images(id, include_image_language: "en,null")
  uri = base_uri("/tv/#{id}/images")
  uri.query = URI.encode_www_form({ include_image_language: include_image_language })
  get_json(uri).with_indifferent_access
end

# --- TV VIDEOS ---
def tv_videos(id)
  uri = base_uri("/tv/#{id}/videos")
  uri.query = URI.encode_www_form({})
  get_json(uri).with_indifferent_access
end

# include_image_language defaults to "<lang>,null" so you get localized + unlabeled images
def tv_images(id, include_image_language: nil)
  lang = (default_query[:language] || "en-US").to_s.split("-").first
  include_image_language ||= "#{lang},null"
  @http.get("tv/#{id}/images", default_query.merge(include_image_language: include_image_language)).body
end

def tv_videos(id)
  @http.get("tv/#{id}/videos", default_query).body
end

# --- If you don't already have this helper in your client, add it once: ---
# Returns the base query hash with api_key + language that your other calls use.
def default_query
  { api_key: ENV.fetch("TMDB_API_KEY"), language: (ENV["TMDB_LANG"] || "en-US") }
end
              
      def movie_images(id, include_image_language: "en,null")
        @http.get("movie/#{id}/images", { include_image_language: include_image_language })
      end

      def movie_videos(id)
        @http.get("movie/#{id}/videos")
      end

      private

      # Helpers to conditionally put correctly-typed values into params
      def map_bool!(h, key, val)
        return if val.nil?
        h[key] = !!val
      end

      def map_str!(h, key, val)
        return if val.nil? || (val.respond_to?(:empty?) && val.empty?)
        h[key] = val.to_s
      end

      def map_num!(h, key, val)
        return if val.nil?
        h[key] = (val.is_a?(Integer) || val.is_a?(Float)) ? val : val.to_s
      end
      



      def get_json(uri)
        req = Net::HTTP::Get.new(uri)
        req["Authorization"] = "Bearer #{@bearer_token}"
        req["Accept"] = "application/json"
        # If using v3 key instead of v4 token:
        req["Content-Type"] = "application/json;charset=utf-8"
        uri = ensure_v3_key(uri) unless @api_key&.start_with?("eyJ")

        Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          res = http.request(req)
          raise "TMDb error: #{res.code} #{res.body}" unless res.is_a?(Net::HTTPSuccess)
          JSON.parse(res.body)
        end
      end

      def ensure_v3_key(uri)
        q = URI.decode_www_form(String(uri.query)) << ["api_key", @api_key]
        uri.tap { |u| u.query = URI.encode_www_form(q) }
      end
    end
  end
end


# module Sources
#   module Tmdb
#     class Client
#        TMDB_HOST = "https://api.themoviedb.org/3"

#   def initialize(api_key: ENV["TMDB_API_KEY"])
#     @api_key = Rails.application.credentials.dig(:tmdb, :api_key)
#     @bearer_token = Rails.application.credentials.dig(:tmdb, :bearer_token)  
#   end

#   # Returns { total_pages: Integer, results: Array<Hash> }
#   def discover_movies(year:, page: 1)
#     uri = URI("#{TMDB_HOST}/discover/movie")
#     params = {
#       page: page,
#       year: year,
#       include_video: false,
#       include_adult: false,
#       sort_by: "popularity.desc",
#       with_release_type: "3|2" # theatrical/limited (tune as you like)
#     }
#     uri.query = URI.encode_www_form(params)

#     json = get_json(uri)
#     {
#       total_pages: json["total_pages"] || 1,
#       results: json["results"] || []
#     }.with_indifferent_access
#   end

#   private

#   def get_json(uri)
#     req = Net::HTTP::Get.new(uri)
#     req["Authorization"] = "Bearer #{@bearer_token}"
#     req["Accept"] = "application/json"
#     # If using v3 key instead of v4 token:
#     req["Content-Type"] = "application/json;charset=utf-8"
#     uri = ensure_v3_key(uri) unless @api_key&.start_with?("eyJ")

#     Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
#       res = http.request(req)
#       raise "TMDb error: #{res.code} #{res.body}" unless res.is_a?(Net::HTTPSuccess)
#       JSON.parse(res.body)
#     end
#   end

#   def ensure_v3_key(uri)
#     q = URI.decode_www_form(String(uri.query)) << ["api_key", @api_key]
#     uri.tap { |u| u.query = URI.encode_www_form(q) }
#   end
  
  
#   def movie_images(id, include_image_language: "en,null")
#     @http.get("movie/#{id}/images", { include_image_language: include_image_language })
#   end

#   def movie_videos(id)
#     @http.get("movie/#{id}/videos")
#   end
#     end
#   end
# end
