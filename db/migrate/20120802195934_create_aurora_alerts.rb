class CreateAuroraAlerts < ActiveRecord::Migration
  def up
    create_table :aurora_alerts do |t|
      t.belongs_to :user, :null => false
      t.datetime :first_sent_at, :null => false
      t.datetime :last_sent_at
      t.integer :times_sent, :null => false, :default => 1
      t.datetime :confirmed_at
      t.datetime :send_reminder_at

      t.timestamps
    end

    add_index :aurora_alerts, [:confirmed_at, :send_reminder_at]
  end

  def down
    remove_index :aurora_alerts, [:confirmed_at, :send_reminder_at]
    drop_table :aurora_alerts
  end
end
