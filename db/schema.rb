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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140710150602) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "alert_permissions", force: true do |t|
    t.integer  "user_id",     null: false
    t.datetime "approved_at"
    t.datetime "expires_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "aurora_alerts", force: true do |t|
    t.integer  "user_id",                      null: false
    t.datetime "first_sent_at",                null: false
    t.datetime "last_sent_at"
    t.integer  "times_sent",       default: 1, null: false
    t.datetime "confirmed_at"
    t.datetime "send_reminder_at"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "aurora_alerts", ["confirmed_at", "send_reminder_at"], name: "index_aurora_alerts_on_confirmed_at_and_send_reminder_at", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "kp_forecasts", force: true do |t|
    t.datetime "forecast_time", null: false
    t.float    "expected_kp",   null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "kp_forecasts", ["forecast_time"], name: "index_kp_forecasts_on_forecast_time", using: :btree

  create_table "message_history", force: true do |t|
    t.string   "mobile_phone",           null: false
    t.string   "message",                null: false
    t.string   "message_type", limit: 2, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "message_history", ["mobile_phone"], name: "index_message_history_on_mobile_phone", using: :btree

  create_table "solar_events", force: true do |t|
    t.string   "message_code",            null: false
    t.string   "serial_number",           null: false
    t.datetime "issue_time",              null: false
    t.string   "expected_storm_strength", null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "solar_events", ["issue_time"], name: "index_solar_events_on_issue_time", using: :btree

  create_table "user_locations", force: true do |t|
    t.integer  "user_id",                      null: false
    t.string   "city",                         null: false
    t.string   "state"
    t.string   "postal_code",       limit: 30
    t.string   "country",           limit: 2,  null: false
    t.float    "latitude",                     null: false
    t.float    "longitude",                    null: false
    t.integer  "magnetic_latitude",            null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "user_locations", ["magnetic_latitude"], name: "index_user_locations_on_magnetic_latitude", using: :btree

  create_table "users", force: true do |t|
    t.string   "mobile_phone", limit: 15, null: false
    t.datetime "confirmed_at"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "users", ["mobile_phone"], name: "index_users_on_mobile_phone", using: :btree

  add_foreign_key "alert_permissions", "users", name: "alert_permissions_user_id_fk"

  add_foreign_key "user_locations", "users", name: "user_locations_user_id_fk"

end
