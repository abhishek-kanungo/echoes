class MediaAsset < ApplicationRecord
  has_many :event_media, dependent: :destroy
  has_many :events, through: :event_media

  enum :media_type, { image: "image", video: "video", audio: "audio" }, prefix: :type
end
