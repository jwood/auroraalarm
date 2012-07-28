class CreateAlertPermissions < ActiveRecord::Migration
  def up
    create_table :alert_permissions do |t|
      t.belongs_to :user, :null => false
      t.datetime :approved_at
      t.datetime :expires_at

      t.timestamps
    end

    add_foreign_key :alert_permissions, :users
  end

  def down
    remove_foreign_key :alert_permissions, :users
    drop_table :alert_permissions
  end
end
