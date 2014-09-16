class MakeUserLocationCityNullable < ActiveRecord::Migration
  def change
    change_column :user_locations, :city, :string, null: true
  end
end
