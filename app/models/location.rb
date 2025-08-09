class Location < ApplicationRecord
  belongs_to :parent, class_name: 'Location', optional: true
  has_many :children, class_name: 'Location', foreign_key: :parent_id, dependent: :nullify

  # Constants for allowed types
  LOCATION_TYPES = %w[world country state city].freeze

  # ✅ Validations
  validates :name, presence: true, length: { maximum: 255 }
  validates :canonical_name, presence: true, length: { maximum: 255 }
  validates :location_type, presence: true, inclusion: { in: LOCATION_TYPES }
  validates :coordinates, presence: true

  validates :canonical_name, uniqueness: { scope: :location_type, case_sensitive: false }
  validates :external_id, uniqueness: { scope: :source }, allow_nil: true

  # 🧼 Normalize name before validation
  before_validation :normalize_names

  private

  def normalize_names
    self.name = name.strip.titleize if name.present?
    self.canonical_name = canonical_name.downcase.strip if canonical_name.present?
  end
end
