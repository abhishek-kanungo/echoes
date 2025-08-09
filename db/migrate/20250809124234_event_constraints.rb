class EventConstraints < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      ALTER TABLE events
      ADD CONSTRAINT events_visibility_check
      CHECK (visibility IN ('public','friends','private'));
    SQL

    # If you use Rails enum for event_type, keep integer; constrain allowed values you actually use.
    # Example allows 0..20 (tune as needed).
    execute <<~SQL
      ALTER TABLE events
      ADD CONSTRAINT events_event_type_check
      CHECK (event_type BETWEEN 0 AND 20);
    SQL
  end

  def down
    execute "ALTER TABLE events DROP CONSTRAINT IF EXISTS events_visibility_check;"
    execute "ALTER TABLE events DROP CONSTRAINT IF EXISTS events_event_type_check;"
  end
end
