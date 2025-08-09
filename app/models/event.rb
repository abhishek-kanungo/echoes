class Event < ApplicationRecord
  belongs_to :submitted_by_user, class_name: 'User', optional: true

  has_many :event_tags, dependent: :delete_all
  has_many :tags, through: :event_tags

  # New associations from your schema
  has_many :event_locations, dependent: :delete_all
  has_many :locations, through: :event_locations

  enum event_type: {
    generic: 0,
    movie: 1,
    music: 2,
    sports: 3,
    gaming: 4,
    tech: 5,
    politics: 6,
    meme: 7,
    education: 8,
    internet: 9,
    fashion: 10,
    history: 11,
    tv: 12
  }, _prefix: :type

  # Align with DB CHECK constraint: 'public' | 'friends' | 'private'
  enum :visibility, {
    visible_to_all: 'public',
    visible_to_self: 'private',
    visible_to_friends: 'friends'
  }

  # ---- Validations
  validates :title, presence: true, length: { maximum: 255 }
  validates :event_date, presence: true
  validates :event_type, presence: true, inclusion: { in: event_types.keys }
  validates :visibility, presence: true, inclusion: { in: visibilities.keys }
  validates :external_id, uniqueness: { scope: :external_source }, allow_nil: true

  # keep event_year synced for indexed queries
  before_validation :set_event_year

  # ---- Scopes (handy for feeds/timelines)
  scope :publicly_visible, -> { where(visibility: visibilities[:visible_to_all]) }
  scope :for_year, ->(y) { where(event_year: y) }
  scope :popular_first, -> { order(Arel.sql('popularity_score DESC NULLS LAST')) }

  private

  def set_event_year
    self.event_year ||= event_date&.year
  end
end
