# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_08_11_213827) do

  create_table "events", force: :cascade do |t|
    t.string "category"
    t.string "item"
    t.string "query"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "action"
    t.bigint "session_id"
    t.string "created_at_string"
    t.index ["created_at_string"], name: "index_events_on_created_at_string"
    t.index ["session_id"], name: "index_events_on_session_id"
  end

  create_table "searches", force: :cascade do |t|
    t.string "query"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "page"
    t.integer "session_id"
    t.string "created_at_string"
    t.index ["created_at_string"], name: "index_searches_on_created_at_string"
    t.index ["session_id"], name: "index_searches_on_session_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_uuid"
    t.datetime "expiry"
    t.boolean "on_campus"
    t.boolean "is_mobile"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "created_at_string"
    t.index ["created_at_string"], name: "index_sessions_on_created_at_string"
  end

end
