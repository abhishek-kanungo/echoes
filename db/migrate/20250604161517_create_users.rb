class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.string :password_digest
      t.date :birth_date
      t.string :birth_location
      t.string :string
      t.string :current_location

      t.timestamps
    end
  end
end
