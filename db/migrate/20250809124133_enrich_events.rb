class EnrichEvents < ActiveRecord::Migration[8.0]
  def change
    # canonical uniqueness for imported rows
    add_index :events, [:external_source, :external_id],
              unique: true, where: "external_source IS NOT NULL AND external_id IS NOT NULL",
              name: "idx_events_unique_external"

    # natural-key fallback when there is no external id (curated/manual)
    add_index :events, [:title, :event_date, :event_type],
              unique: true, where: "external_source IS NULL",
              name: "idx_events_unique_natural_partial"

    # fast timeline queries
    add_index :events, :event_date

    # metadata search
    enable_extension "pg_trgm" unless extension_enabled?("pg_trgm")
    add_index :events, :metadata, using: :gin, name: "idx_events_metadata_gin"
    add_index :events, "lower(title) gin_trgm_ops", using: :gin, name: "idx_events_title_trgm"

    # quality signals + source audit
    add_column :events, :popularity_score, :float
    add_column :events, :impact_score, :float
    add_column :events, :confidence, :float
    add_column :events, :source_url, :text

    # helpful generated year for partitioning/analytics (optional)
    add_column :events, :event_year, :int
    add_index  :events, :event_year
  end
end
