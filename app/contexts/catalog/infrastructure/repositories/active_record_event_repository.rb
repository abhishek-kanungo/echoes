module Catalog
  class ActiveRecordEventRepository
    def upsert_external(mapped)
      attrs = to_attrs(mapped)
      Event.upsert(attrs, unique_by: :idx_events_unique_external)
      Event.find_by!(external_source: attrs[:external_source], external_id: attrs[:external_id])
    end

    def upsert_curated(mapped)
      attrs = to_attrs(mapped).merge(external_source: nil, external_id: nil)
      Event.upsert(attrs, unique_by: :idx_events_unique_natural_partial)
      Event.find_by!(title: attrs[:title], event_date: attrs[:event_date], event_type: attrs[:event_type])
    end

    def link_locations(event_id, links)
      links.each do |link|
        EventLocation.find_or_create_by!(event_id:, location_id: link[:location_id], role: link[:role] || "venue")
      end
    end

    private

    def to_attrs(m)
      {
        title: m[:title],
        description: m[:description],
        event_date: m[:event_date],
        event_year: m[:event_date]&.year,
        event_type: Event.event_types[m[:event_type].to_s], # symbol or string
        visibility: "public",
        cover_image_url: m[:cover_image_url],
        external_id: m[:external_id],
        external_source: m[:external_source],
        source_url: m[:source_url],
        popularity_score: m[:popularity_score],
        impact_score: m[:impact_score],
        confidence: m[:confidence],
        metadata: m[:metadata] || {}
      }
    end
  end
end
