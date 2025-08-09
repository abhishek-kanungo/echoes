namespace :tmdb do
  desc "Import TMDB movies by year. Usage: rake tmdb:import_movies YEAR=1999 [PAGE_LIMIT=3]"
  task import_movies: :environment do
    year = ENV["YEAR"]&.to_i
    page_limit = ENV["PAGE_LIMIT"]&.to_i if ENV["PAGE_LIMIT"]

    if year.nil? || year <= 0
      puts "❌ You must pass a valid YEAR (e.g. rake tmdb:import_movies YEAR=1999)"
      exit(1)
    end

    puts "📆 Starting TMDB import for year #{year}..."
    Tmdb::MovieImporter.new.import_year(year, page_limit: page_limit)
    puts "✅ Finished importing movies for #{year}"
  end
end
