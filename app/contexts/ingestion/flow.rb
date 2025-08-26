module Ingestion
  class Flow
    def initialize(event_repo: Catalog::ActiveRecordEventRepository.new)
      @event_repo = event_repo
    end

    # Process one ingest row end-to-end with stdout logging
    def call(ingest_id)
      ingest = Ingest.find(ingest_id)
      EchoesLogger.start("FLOW", "Processing ingest", ingest_id: ingest.id, source: ingest.source)

      raw = ingest.payload
      mapped = map_payload(ingest.source, raw)
      EchoesLogger.ok("MAP", "Mapped payload", external_id: mapped[:external_id], title: mapped[:title])

      pass, reasons = QualityPolicy.check(mapped)
      if pass
        EchoesLogger.ok("QUALITY", "Passed")
      else
        EchoesLogger.fail("QUALITY", "Failed", reasons: reasons)
        ingest.mark!("skipped", error_message: reasons.join(", "))
        return
      end

      event =
        if DedupPolicy.external?(mapped)
          EchoesLogger.log("UPSERT", "External upsert", key: [mapped[:external_source], mapped[:external_id]])
          @event_repo.upsert_external(mapped)
        else
          EchoesLogger.log("UPSERT", "Curated upsert", title: mapped[:title])
          @event_repo.upsert_curated(mapped)
        end

      EchoesLogger.ok("EVENT", "Upserted event", event_id: event.id, external_source: event.external_source)

      ingest.mark!("upserted", event_id: event.id)
      EchoesLogger.ok("INGEST", "Marked upserted", ingest_id: ingest.id)

      # Trigger media for TMDb
      if event.external_source == "tmdb"
        TmdbMovieAssetsFetchWorker.perform_async(event.id)
        EchoesLogger.log("ENQUEUE", "Media worker enqueued", event_id: event.id)
      end
    rescue => e
      EchoesLogger.fail("FLOW", "Error", error: e.message, backtrace: e.backtrace&.first(5))
      ingest&.mark!("error", error_message: e.message.to_s[0,1000]) rescue nil
      raise
    end

    private
    def map_payload(source, raw)
      case source
      when "tmdb" then Sources::Tmdb::Mapper.to_mapped_event(raw).with_indifferent_access
      else
        raise "Unknown source: #{source}"
      end
    end
  end
end
