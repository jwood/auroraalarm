# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120718202652) do

  create_table "users", :force => true do |t|
    t.string   "mobile_phone", :limit => 15, :null => false
    t.integer  "zipcode_id",                 :null => false
    t.datetime "confirmed_at"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "users", ["mobile_phone"], :name => "index_users_on_mobile_phone"
  add_index "users", ["zipcode_id", "confirmed_at"], :name => "index_users_on_zipcode_id_and_confirmed_at"

  create_table "zipcodes", :force => true do |t|
    t.string   "code",              :limit => 25, :null => false
    t.float    "latitude",                        :null => false
    t.float    "longitude",                       :null => false
    t.integer  "magnetic_latitude",               :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "zipcodes", ["code"], :name => "index_zipcodes_on_code"
  add_index "zipcodes", ["magnetic_latitude"], :name => "index_zipcodes_on_magnetic_latitude"

  add_foreign_key "users", "zipcodes", :name => "users_zipcode_id_fk"

end
