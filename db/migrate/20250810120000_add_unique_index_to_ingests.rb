# db/migrate/20250810120000_add_unique_index_to_ingests.rb
# frozen_string_literal: true
class AddUniqueIndexToIngests < ActiveRecord::Migration[8.0]
  def up
    # Defensive: ensure required columns exist
    add_column :ingests, :source, :string, null: false, default: "" unless column_exists?(:ingests, :source)
    add_column :ingests, :external_id, :string, null: false, default: "" unless column_exists?(:ingests, :external_id)
    add_column :ingests, :topic, :string, null: false, default: "" unless column_exists?(:ingests, :topic)

    # Idempotent unique index for (source, external_id, topic)
    unless index_exists?(:ingests, [:source, :external_id, :topic], unique: true, name: "idx_ingests_unique")
      execute <<~SQL
        CREATE UNIQUE INDEX idx_ingests_unique ON ingests (source, external_id, topic);
      SQL
    end
  end

  def down
    remove_index :ingests, name: "idx_ingests_unique" if index_exists?(:ingests, [:source, :external_id, :topic], unique: true, name: "idx_ingests_unique")
    # Leave columns in place; they might be used elsewhere.
  end
end
