# frozen_string_literal: true
class AddEventTypeToUniqueIndexes < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    say_with_time "[MIG] Updating unique indexes to include event_type" do
      # External source-based unique index
      if index_exists?(:events, [:external_source, :external_id], name: "idx_events_unique_external")
        remove_index :events, name: "idx_events_unique_external", algorithm: :concurrently
      end
      unless index_exists?(:events, [:external_source, :external_id, :event_type], name: "idx_events_unique_external")
        add_index :events,
                  [:external_source, :external_id, :event_type],
                  unique: true,
                  name: "idx_events_unique_external",
                  algorithm: :concurrently
      end

      # Natural key partial unique index (manual/curated events)
      if index_exists?(:events, [:title, :event_date, :event_type], name: "idx_events_unique_natural_partial")
        remove_index :events, name: "idx_events_unique_natural_partial", algorithm: :concurrently
      end
      unless index_exists?(:events, [:title, :event_date, :event_type], name: "idx_events_unique_natural_partial")
        add_index :events,
                  [:title, :event_date, :event_type],
                  unique: true,
                  where: "external_source IS NULL",
                  name: "idx_events_unique_natural_partial",
                  algorithm: :concurrently
      end
    end
  end

  def down
    say_with_time "[MIG] Reverting unique indexes to previous state" do
      # External source-based index back to old scope
      if index_exists?(:events, [:external_source, :external_id, :event_type], name: "idx_events_unique_external")
        remove_index :events, name: "idx_events_unique_external", algorithm: :concurrently
      end
      add_index :events,
                [:external_source, :external_id],
                unique: true,
                name: "idx_events_unique_external",
                algorithm: :concurrently

      # Natural key partial back to old state
      if index_exists?(:events, [:title, :event_date, :event_type], name: "idx_events_unique_natural_partial")
        remove_index :events, name: "idx_events_unique_natural_partial", algorithm: :concurrently
      end
      add_index :events,
                [:title, :event_date],
                unique: true,
                where: "external_source IS NULL",
                name: "idx_events_unique_natural_partial",
                algorithm: :concurrently
    end
  end
end
