class CreateMessageHistory < ActiveRecord::Migration
  def up
    create_table :message_history do |t|
      t.string :mobile_phone, :null => false
      t.string :message, :null => false
      t.string :message_type, :null => false, :limit => 2

      t.timestamps
    end

    add_index :message_history, :mobile_phone
  end

  def down
    remove_index :message_history, :mobile_phone
    drop_table :message_history
  end
end
