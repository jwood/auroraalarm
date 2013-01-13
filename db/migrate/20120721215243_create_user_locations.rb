class CreateUserLocations < ActiveRecord::Migration
  def up
    create_table :user_locations do |t|
      t.belongs_to :user, null: false
      t.string :city, null: false
      t.string :state
      t.string :postal_code, limit: 30
      t.string :country, null: false, limit: 2
      t.float :latitude, null: false
      t.float :longitude, null: false
      t.integer :magnetic_latitude, null: false

      t.timestamps
    end

    add_index :user_locations, :magnetic_latitude
    add_foreign_key :user_locations, :users

    remove_foreign_key :users, :zipcodes
    remove_index :users, [:zipcode_id, :confirmed_at]
    remove_column :users, :zipcode_id
  end

  def down
    add_column :users, :zipcode_id, :integer, null: false
    add_index :users, [:zipcode_id, :confirmed_at]
    add_foreign_key :users, :zipcodes

    remove_foreign_key :user_locations, :users
    remove_index :user_locations, :magnetic_latitude
    drop_table :user_locations
  end
end
