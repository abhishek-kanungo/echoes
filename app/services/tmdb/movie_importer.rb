require 'net/http'
require 'uri'
require 'json'

module Tmdb
  class MovieImporter
    BASE_URL = "https://api.themoviedb.org/3"
    RATE_LIMIT_DELAY = 0.25 # TMDB free tier allows 4 requests/sec

    def initialize
      @token = Rails.application.credentials.dig(:tmdb, :bearer_token)
    end

    # ✅ Import a single movie by its TMDB ID
    def import_movie_by_id(movie_id)
      response = get("/movie/#{movie_id}")
      puts "🎬 Fetched movie: #{response['title']} (#{response['release_date']})"
      import_movie(response)
    rescue => e
      puts "❌ Error importing movie ID #{movie_id}: #{e.class} - #{e.message}"
      puts e.backtrace.take(10).join("\n")
    end

    # ✅ Import popular movies for a specific year
    def import_year(year, page_limit: nil)
        page = 1

        loop do
        puts "\n📆 Importing #{year}, page #{page}"
        response = get("/discover/movie", {
            primary_release_year: year,
            sort_by: "popularity.desc",
            page: page
        })

        break if response['results'].blank?

        response['results'].each do |summary|
            begin
            movie = get("/movie/#{summary['id']}")
            puts "🎬 #{movie['title']} (#{movie['release_date']})"
            import_movie(movie)
            rescue => e
            puts "⚠️ Failed to import #{summary['title']} (#{summary['id']}): #{e.message}"
            end
        end

        page += 1
        break if page_limit && page > page_limit
        break if page > response['total_pages']
        end
    end


    # ✅ Core logic to create the Event and attach tags
    def import_movie(movie_data)
      event = Event.new(
        title: movie_data['title'],
        description: movie_data['overview'],
        event_date: movie_data['release_date'],
        event_type: :movie,
        visibility: :visible_to_all,
        external_id: movie_data['id'],
        external_source: 'tmdb',
        metadata: movie_data.slice(
          'popularity',
          'vote_average',
          'poster_path',
          'backdrop_path',
          'original_language',
          'runtime',
          'tagline'
        )
      )

      if event.save
        attach_genre_tags(event, movie_data['genres'])
        puts "✅ Saved movie: #{event.title} (#{event.event_date})"
      else
        puts "❌ Failed to save: #{event.title} (#{event.event_date}) – #{event.errors.full_messages.join(', ')}"
      end
    end

    private

    # ✅ TMDB API helper
    def get(path, params = {})
      url = URI("#{BASE_URL}#{path}")
      url.query = URI.encode_www_form(params) if params.any?

      headers = {
        "Authorization" => "Bearer #{@token}",
        "Accept" => "application/json"
      }

      response = Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
        req = Net::HTTP::Get.new(url, headers)
        http.request(req)
      end

      sleep(RATE_LIMIT_DELAY)

      raise "TMDB Error: #{response.code} – #{response.message}" unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    end

    # ✅ Tag creation + association based on TMDB genres
   def attach_genre_tags(event, genres)
        return unless genres.is_a?(Array)

        genres.each do |genre|
            name = genre['name']
            next if name.blank?

            tag = Tag.find_by(name: name, tag_type: 'genre')

            unless tag
            tag = Tag.new(name: name, tag_type: 'genre')
            unless tag.save
                puts "❌ Failed to create tag '#{name}': #{tag.errors.full_messages.join(', ')}"
                next
            end
            end

            EventTag.find_or_create_by!(event: event, tag: tag)
        end
    end


  end
end
