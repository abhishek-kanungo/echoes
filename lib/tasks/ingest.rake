namespace :ingest do
  desc "Fetch TMDb discover for a given year (and pages)"
  task :tmdb, [:year, :pages] => :environment do |_, args|
    year  = args[:year].to_i
    pages = (args[:pages] || 2).to_i
    raise "year required" if year.zero?

    TmdbDiscoverFetchWorker.perform_async(year, pages)
    puts "Enqueued TMDb discover: year=\#{year}, pages=\#{pages}"
  end
end
