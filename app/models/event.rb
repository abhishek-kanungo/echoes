class Event < ApplicationRecord
  belongs_to :submitted_by_user, class_name: 'User', optional: true
  has_many :event_tags
  has_many :tags, through: :event_tags
  
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
  

  enum :visibility, {
    visible_to_all: 'public',
    visible_to_self: 'private',
    visible_to_friends: 'friends_only'
  }

  validates :title, presence: true, length: { maximum: 255 }
  validates :event_date, presence: true
  validates :event_type, presence: true, inclusion: { in: event_types.keys }
  validates :visibility, presence: true, inclusion: { in: visibilities.keys }
  validates :external_id, uniqueness: { scope: :external_source }, allow_nil: true
end
