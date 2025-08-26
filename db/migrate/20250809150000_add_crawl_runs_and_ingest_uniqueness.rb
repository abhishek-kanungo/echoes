class AddCrawlRunsAndIngestUniqueness < ActiveRecord::Migration[7.1]
  def change
    create_table :crawl_runs do |t|
      t.string  :source, null: false      # e.g., "tmdb"
      t.string  :topic,  null: false      # e.g., "discover:movies"
      t.integer :year,   null: false
      t.integer :current_page, null: false, default: 0
      t.integer :total_pages
      t.string  :status, null: false, default: "running" # running|paused|done|error
      t.text    :last_error
      t.timestamps
    end
    add_index :crawl_runs, [:source, :topic, :year], unique: true
    # Avoid duplicate ingests on retries for the same source/external/topic tuple
    add_index :ingests, [:source, :external_id, :topic], unique: true, name: :idx_ingests_source_external_topic
  end
end
