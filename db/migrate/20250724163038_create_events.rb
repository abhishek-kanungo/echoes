class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :title, null: false
      t.text :description
      t.date :event_date
      
      t.integer :event_type, null: false, default: 0
      
      t.references :submitted_by_user, foreign_key: { to_table: :users}, null: true
    # t.references :location, foreign_key: true, null: true
      t.string :visibility, default: 'public', null: false

      # Optional cover image for event cards
      t.text :cover_image_url

      t.string :external_id    # e.g. TMDB movie ID, Wikipedia slug, etc.
      t.string :external_source # e.g. 'tmdb', 'wikipedia', 'bookmyshow'
      # Flexible metadata for category-specific details
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
    end
  end
end
