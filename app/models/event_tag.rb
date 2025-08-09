class EventTag < ApplicationRecord
  belongs_to :event
  belongs_to :tag

  # Ensure presence of both associations
  validates :event_id, presence: true
  validates :tag_id, presence: true

  # Prevent duplicate event-tag associations
  validates :tag_id, uniqueness: { scope: :event_id, message: "already tagged to this event" }
end