#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-.}"
echo "[INSTALL] copying files into ${ROOT}"
install -d "${ROOT}/app/services/ingestion" "${ROOT}/app/workers"
cp "app/services/ingestion/tmdb_sync.rb" "${ROOT}/app/services/ingestion/tmdb_sync.rb"
cp "app/workers/tmdb_discover_coordinator_sync_worker.rb" "${ROOT}/app/workers/tmdb_discover_coordinator_sync_worker.rb"
echo "[INSTALL] done. Next steps:"
echo "  1) git add app/services/ingestion/tmdb_sync.rb app/workers/tmdb_discover_coordinator_sync_worker.rb"
echo "  2) git commit -m 'TMDB: synchronous ingest path + reduced API calls'"
echo "  3) bundle exec sidekiq (or restart your worker)"
echo "  4) rails c -> TmdbDiscoverCoordinatorSyncWorker.perform_async(2025)"
