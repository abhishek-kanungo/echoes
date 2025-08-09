class CreateEventLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :event_locations do |t|
      t.references :event, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.string :role, null: false, default: "venue" # e.g., venue|host_country|origin|final
      t.timestamps
    end

    add_index :event_locations, [:event_id, :location_id, :role],
              unique: true, name: "idx_event_locations_unique"
  end
end
