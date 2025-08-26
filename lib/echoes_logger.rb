module EchoesLogger
  # Usage: EchoesLogger.log(step, "message", extra_hash)
  def self.log(step, message, extra = {})
    prefix = "[#{step}]"
    suffix = extra.present? ? " " + extra.to_json : ""
    Rails.logger.info("#{prefix} #{message}#{suffix}")
  rescue => e
    # Fallback to STDOUT if Rails.logger isn't ready
    puts("#{prefix} #{message} #{extra.inspect} (logger error: #{e.message})")
  end

  def self.start(step, message, extra = {})
    log("#{step}_START", message, extra)
  end

  def self.ok(step, message, extra = {})
    log("#{step}_OK", message, extra)
  end

  def self.fail(step, message, extra = {})
    log("#{step}_ERROR", message, extra)
  end
end
