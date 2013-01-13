class CreateSolarEvents < ActiveRecord::Migration
  def up
    create_table :solar_events do |t|
      t.string :message_code, length: 15, null: false
      t.string :serial_number, length: 15, null: false
      t.datetime :issue_time, null: false
      t.string :expected_storm_strength, length: 3, null: false

      t.timestamps
    end

    add_index :solar_events, :issue_time
  end

  def down
    remove_index :solar_events, :issue_time
    drop_table :solar_events
  end
end
