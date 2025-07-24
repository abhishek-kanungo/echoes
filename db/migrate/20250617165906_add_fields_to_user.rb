class AddFieldsToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :google_uid, :string           # maps to 'sub'
    add_column :users, :email_verified, :boolean
    add_column :users, :avatar_url, :string           # maps to 'picture'
    add_column :users, :locale, :string
    add_column :users, :birthday, :date
    add_column :users, :gender, :string
    
    add_index :users, :google_uid, unique: true
    add_index :users, :email
  end
end
