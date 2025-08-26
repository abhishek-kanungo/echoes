# frozen_string_literal: true
module Catalog
  class ActiveRecordEventRepository
    # Upsert events that come from an external source (e.g., TMDb)
    # Expected keys in mapped:
    #   :external_source, :external_id, :title, :event_date, :event_type,
    #   :description, :cover_image_url, :metadata (Hash), :visibility
    def upsert_external(mapped)
      raise ArgumentError, "external_source/external_id required" unless mapped[:external_source].present? && mapped[:external_id].present?

      attrs = normalized_attrs(mapped)
      # ensure partial unique index (external_source, external_id) is used
      event = Event.find_or_initialize_by(
        external_source: attrs[:external_source],
        external_id:     attrs[:external_id]
      )
      event.assign_attributes(attrs.except(:external_source, :external_id))
      event.save!
      event
    end

    # Upsert events without an external identity (curated items)
    # Uses natural-keys partial unique index: (title, event_date, event_type) WHERE external_source IS NULL
    def upsert_curated(mapped)
      attrs = normalized_attrs(mapped).merge(external_source: nil, external_id: nil)
      event = Event.find_or_initialize_by(
        title: attrs[:title],
        event_date: attrs[:event_date],
        event_type: attrs[:event_type]
      )
      event.assign_attributes(attrs)
      event.save!
      event
    end

    private

    def normalized_attrs(m)
      {
        title:            m[:title],
        description:      m[:description],
        event_date:       m[:event_date] || (m[:event_year] && Date.new(m[:event_year].to_i, 1, 1)),
        event_type:       m[:event_type] || :movie, # default if mapper didn’t set
        visibility:       m[:visibility] || Event.visibilities.keys.first, # e.g. "public"
        cover_image_url:  m[:cover_image_url],
        metadata:         (m[:metadata] || {}).with_indifferent_access,
        external_source:  m[:external_source],
        external_id:      m[:external_id],
        event_year:       m[:event_year] || safe_year(m[:event_date]),
        popularity_score: m[:popularity_score],
        impact_score:     m[:impact_score],
        confidence:       m[:confidence],
        source_url:       m[:source_url]
      }.compact
    end

    def safe_year(date)
      date.respond_to?(:year) ? date.year : nil
    end
  end
end
