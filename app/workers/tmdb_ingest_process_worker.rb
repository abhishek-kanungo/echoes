class TmdbIngestProcessWorker
  include Sidekiq::Worker
  sidekiq_options queue: :ingest, retry: 5

  def perform(ingest_id)
    Ingestion::Flow.new.call(ingest_id)
  end
end
