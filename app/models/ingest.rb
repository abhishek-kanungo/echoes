class Ingest < ApplicationRecord
  belongs_to :event, optional: true

  enum :status, {
    pending: "pending",
    validated: "validated",
    mapped: "mapped",
    upserted: "upserted",
    skipped: "skipped",
    error: "error"
  }, _prefix: :status

  validates :source, presence: true
  validates :payload, presence: true

  def mark!(new_status, attrs = {})
    update!(attrs.merge(status: new_status))
  end
end
