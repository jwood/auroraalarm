class CreateKpForecasts < ActiveRecord::Migration
  def up
    create_table :kp_forecasts do |t|
      t.datetime :forecast_time, null: false
      t.float :expected_kp, null: false

      t.timestamps
    end

    add_index :kp_forecasts, :forecast_time
  end

  def down
    remove_index :kp_forecasts, :forecast_time
    drop_table :kp_forecasts
  end
end
