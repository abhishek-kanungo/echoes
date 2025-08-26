class CreateMediaAssetsAndEventMedia < ActiveRecord::Migration[7.1]
  def change
    create_table :media_assets do |t|
      t.string  :provider, null: false      # "tmdb","youtube","vimeo","imdb"
      t.string  :external_id                # TMDb file_path, YouTube key, etc.
      t.string  :media_type, null: false    # "image","video","audio"
      t.string  :subtype                    # "poster","backdrop","still","trailer","teaser","clip"
      t.string  :url, null: false
      t.string  :preview_url
      t.string  :mime
      t.integer :width
      t.integer :height
      t.float   :aspect_ratio
      t.string  :language
      t.integer :vote_count
      t.float   :vote_average
      t.jsonb   :metadata, null: false, default: {}
      t.timestamps
    end
    add_index :media_assets, [:provider, :external_id, :subtype], unique: true, name: :idx_media_provider_external

    create_table :event_media do |t|
      t.references :event, null: false, foreign_key: true
      t.references :media_asset, null: false, foreign_key: true
      t.string  :role, null: false, default: "gallery"   # "poster","cover","hero","gallery","trailer"
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :event_media, [:event_id, :media_asset_id], unique: true
    add_index :event_media, [:event_id, :role, :position]
  end
end
