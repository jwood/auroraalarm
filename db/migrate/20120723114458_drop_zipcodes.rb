class DropZipcodes < ActiveRecord::Migration
  def up
    remove_index :zipcodes, :code
    remove_index :zipcodes, :magnetic_latitude
    drop_table :zipcodes
  end

  def down
    create_table :zipcodes do |t|
      t.string :code, :limit => 25, :null => false
      t.float :latitude, :null => false
      t.float :longitude, :null => false
      t.integer :magnetic_latitude, :null => false

      t.timestamps
    end

    add_index :zipcodes, :code
    add_index :zipcodes, :magnetic_latitude
  end
end
