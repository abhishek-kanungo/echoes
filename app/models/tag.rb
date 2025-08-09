class Tag < ApplicationRecord
  # 🚫 Disable STI behavior
  self.inheritance_column = :_type_disabled

  # ✅ Validation rules
  validates :name, presence: true, uniqueness: { scope: :tag_type, case_sensitive: false }
  validates :tag_type, presence: true

  # Optional: restrict allowed tag types
  TAG_TYPES = %w[category generation theme location_scope genre]

  validates :tag_type, inclusion: { in: TAG_TYPES }

  # 🔍 Normalize name before saving
  before_validation :normalize_name

  private

  def normalize_name
    self.name = name.strip.titleize if name.present?
  end
end
