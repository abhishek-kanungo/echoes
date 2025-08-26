module IngestLogger
  def ilog(event, data = {})
    payload = {
      ts: Time.now.utc.iso8601,
      event: event,
      klass: self.class.name
    }
    payload[:jid] = jid if respond_to?(:jid) && jid
    payload.merge!(data) if data
    Rails.logger.info("[INGEST] #{payload.to_json}")
  end
end