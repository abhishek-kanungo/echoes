class CreateLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :locations do |t|
      t.string :name, null: false
      t.string :canonical_name, null: false
      t.string :location_type, null: false
      t.string :iso_code
      t.string :aliases, array: true, default: []
      t.references :parent, foreign_key: { to_table: :locations }

      # 👇 Raw PostGIS point column (works without adapter)
      t.column :coordinates, 'geography(Point,4326)', null: false

      t.string :external_id
      t.string :source

      t.timestamps
    end

    add_index :locations, [:canonical_name, :location_type], unique: true
    add_index :locations, :aliases, using: :gin
    add_index :locations, :coordinates, using: :gist
    add_index :locations, :iso_code
  end
end
