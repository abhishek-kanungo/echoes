module Ingestion
  class DedupPolicy
    def self.external?(mapped)
      mapped[:external_source].present? && mapped[:external_id].present?
    end
  end
end
