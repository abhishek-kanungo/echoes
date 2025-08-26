Echoes — Resumable TMDb Crawl + Media Assets

1) Unzip this archive at your Rails repo root (paths match app/, lib/, db/).
2) Run migrations:
     bundle exec rails db:migrate
3) Ensure autoload for lib/ is enabled in config/application.rb:
     config.eager_load_paths << Rails.root.join("lib")
4) Ensure TMDb client has:
     BASE = "https://api.themoviedb.org/3/"
     and calls like @http.get("discover/movie", params)
   Also add the methods from lib/sources/tmdb/client_additions.README.txt.
5) Start Sidekiq:
     bundle exec sidekiq -q ingest -q default

Run last year ingestion (rails console):
  last_year = Time.zone.now.year - 1
  TmdbDiscoverCoordinatorWorker.perform_async(last_year)

Resume behavior:
  - Re-run the worker at any time; it continues from CrawlRun.current_page + 1
  - Unique index on ingests (source, external_id, topic) prevents duplicate rows
  - Event.upsert with unique idx prevents duplicate events

Media fetching:
  - After each event upsert, TmdbMovieAssetsFetchWorker runs to store up to 6 posters, 6 backdrops, and up to 3 trailers.
  - Data saved in media_assets and event_media with roles and positions.

Verify:
  CrawlRun.find_by(source: "tmdb", topic: "discover:movies", year: last_year)&.slice(:current_page,:total_pages,:status)
  Ingest.where("topic LIKE ?", "tmdb:discover:#{last_year}:%").group(:status).count
  Event.where(external_source: "tmdb", event_year: last_year).count
  Event.last.media_assets.pluck(:subtype, :provider, :url).first(5)

Notes:
  - Keep TMDb attribution as required. We hotlink to TMDb images and YouTube for videos.
  - If you later mirror to S3, add storage_url in metadata and switch the API to prefer your CDN.
