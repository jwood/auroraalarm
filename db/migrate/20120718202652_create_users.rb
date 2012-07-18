class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :mobile_phone, :limit => 15, :null => false
      t.belongs_to :zipcode, :null => false
      t.datetime :confirmed_at

      t.timestamps
    end

    add_index :users, :mobile_phone
    add_index :users, [:zipcode_id, :confirmed_at]
    add_foreign_key :users, :zipcodes
  end

  def down
    remove_foreign_key :users, :zipcodes
    remove_index :users, :mobile_phone
    remove_index :users, [:zipcode_id, :confirmed_at]
    drop_table :users
  end
end
