class CreateIngests < ActiveRecord::Migration[8.0]
  def change
    create_table :ingests do |t|
      t.string  :source, null: false         # e.g., 'tmdb', 'musicbrainz', 'wikipedia'
      t.string  :external_id
      t.string  :topic                       # e.g., 'movies:year:2012', 'tennis:slams:1980-2024'
      t.jsonb   :payload, null: false, default: {}
      t.string  :status,  null: false, default: "pending"  # pending|ok|skipped|error
      t.text    :error_message
      t.references :event, foreign_key: true # link when normalized
      t.timestamps
    end

    add_index :ingests, [:source, :external_id], name: "idx_ingests_source_external"
    add_index :ingests, :status
    add_index :ingests, :topic
  end
end
