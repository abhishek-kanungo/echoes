module Catalog
  class MediaRepository
    def upsert_and_link!(event:, attrs:, role:, position: 0)
      asset = MediaAsset.find_or_initialize_by(
        provider:   attrs[:provider],
        external_id: attrs[:external_id],
        subtype:     attrs[:subtype]
      )
      asset.assign_attributes(attrs)
      asset.save!

      EventMedia.find_or_create_by!(event: event, media_asset: asset) do |em|
        em.role = role
        em.position = position
      end

      asset
    end
  end
end
