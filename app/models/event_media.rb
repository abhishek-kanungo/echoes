class EventMedia < ApplicationRecord
  belongs_to :event
  belongs_to :media_asset
  default_scope { order(position: :asc, id: :asc) }
end
