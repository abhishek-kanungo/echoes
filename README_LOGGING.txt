Echoes STDOUT Logging Patch
---------------------------
This patch adds detailed Rails logger output for the ingestion lifecycle.

Files:
  - lib/echoes_logger.rb
  - app/workers/tmdb_discover_coordinator_worker.rb (instrumented)
  - app/workers/tmdb_movie_assets_fetch_worker.rb (instrumented)
  - app/contexts/ingestion/application/flow.rb (instrumented)

Install:
  unzip echoes_logging_patch.zip -d .
  # ensure lib/ is autoloaded in config/application.rb:
  #   config.eager_load_paths << Rails.root.join("lib")
  # dev log level:
  #   config/environments/development.rb -> config.log_level = :info

Run (no Sidekiq):
  rails c
  TmdbDiscoverCoordinatorWorker.new.perform(2025)

Run (with Sidekiq):
  bundle exec sidekiq -q ingest -q default

You should see step-by-step messages such as:
  [CRAWL_START] TMDb discover movies {"year":2025}
  [FETCH_PAGE_OK] Fetched page {"page":1,"total_pages":753,"count":20}
  [INGEST_CREATE_OK] Queued ingest {"id":123,"tmdb_id":999,"title":"Example"}
  [FLOW_START] Processing ingest {"ingest_id":123,"source":"tmdb"}
  [EVENT_OK] Upserted event {"event_id":456,"external_source":"tmdb"}
  [ENQUEUE] Media worker enqueued {"event_id":456}
