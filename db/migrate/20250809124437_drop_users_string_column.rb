class DropUsersStringColumn < ActiveRecord::Migration[8.0]
  def change
    # This column looks accidental.
    remove_column :users, :string, :string
  end
end
