module Ingestion
  class Flow
    def initialize(event_repo: Catalog::ActiveRecordEventRepository.new)
      @event_repo = event_repo
    end

    # Process one ingest row end-to-end
    def call(ingest_id)
      ingest = Ingest.find(ingest_id)
      raw = ingest.payload
      mapped = map_payload(ingest.source, raw)

      pass, reasons = QualityPolicy.check(mapped)
      unless pass
        ingest.mark!("skipped", error_message: reasons.join(", "))
        return
      end

      event =
        if DedupPolicy.external?(mapped)
          @event_repo.upsert_external(mapped)
        else
          @event_repo.upsert_curated(mapped)
        end

      ingest.mark!("upserted", event_id: event.id)
    rescue => e
      ingest.mark!("error", error_message: e.message.to_s[0,1000])
      raise
    end

    private
    def map_payload(source, raw)
      source == "tmdb" ? Sources::Tmdb::Mapper.to_mapped_event(raw).with_indifferent_access : (raise "Unknown source: \#{source}")
    end
  end
end
