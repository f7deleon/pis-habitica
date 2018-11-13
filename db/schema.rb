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

ActiveRecord::Schema.define(version: 2018_11_08_002049) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "characters", force: :cascade do |t|
    t.string "name"
    t.string "description"
  end

  create_table "friendships", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "friend_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["friend_id"], name: "index_friendships_on_friend_id"
    t.index ["user_id"], name: "index_friendships_on_user_id"
  end

  create_table "group_habit_has_types", force: :cascade do |t|
    t.bigint "habit_id"
    t.bigint "type_id"
    t.index ["habit_id"], name: "index_group_habit_has_types_on_habit_id"
    t.index ["type_id"], name: "index_group_habit_has_types_on_type_id"
  end

  create_table "group_requests", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "group_id"
    t.bigint "receiver_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_group_requests_on_group_id"
    t.index ["receiver_id"], name: "index_group_requests_on_receiver_id"
    t.index ["user_id"], name: "index_group_requests_on_user_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "privacy"
  end

  create_table "habits", force: :cascade do |t|
    t.string "type"
    t.string "name"
    t.string "description"
    t.integer "difficulty"
    t.integer "privacy"
    t.integer "frequency"
    t.boolean "active"
    t.bigint "user_id"
    t.bigint "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "negative"
    t.index ["group_id"], name: "index_habits_on_group_id"
    t.index ["user_id"], name: "index_habits_on_user_id"
  end

  create_table "individual_habit_has_types", force: :cascade do |t|
    t.bigint "habit_id"
    t.bigint "type_id"
    t.index ["habit_id"], name: "index_individual_habit_has_types_on_habit_id"
    t.index ["type_id"], name: "index_individual_habit_has_types_on_type_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "group_id"
    t.boolean "admin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "score"
    t.index ["group_id"], name: "index_memberships_on_group_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "type"
    t.integer "sender_id"
    t.integer "user_id"
    t.bigint "group_id"
    t.bigint "request_id"
    t.bigint "track_individual_habit_id"
    t.boolean "seen"
    t.bigint "group_request_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_notifications_on_group_id"
    t.index ["group_request_id"], name: "index_notifications_on_group_request_id", unique: true
    t.index ["request_id"], name: "index_notifications_on_request_id", unique: true
    t.index ["track_individual_habit_id"], name: "index_notifications_on_track_individual_habit_id", unique: true
  end

  create_table "requests", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "receiver_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["receiver_id"], name: "index_requests_on_receiver_id"
    t.index ["user_id"], name: "index_requests_on_user_id"
  end

  create_table "track_group_habits", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "habit_id"
    t.datetime "date"
    t.integer "health_difference"
    t.integer "experience_difference"
    t.integer "score_difference"
    t.index ["habit_id"], name: "index_track_group_habits_on_habit_id"
    t.index ["user_id"], name: "index_track_group_habits_on_user_id"
  end

  create_table "track_individual_habits", force: :cascade do |t|
    t.bigint "habit_id"
    t.integer "health_difference"
    t.integer "experience_difference"
    t.datetime "date"
    t.index ["habit_id"], name: "index_track_individual_habits_on_habit_id"
  end

  create_table "types", force: :cascade do |t|
    t.string "type"
    t.string "name"
    t.string "description"
    t.bigint "group_id"
    t.bigint "user_id"
    t.index ["group_id"], name: "index_types_on_group_id"
    t.index ["user_id"], name: "index_types_on_user_id"
  end

  create_table "user_characters", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "character_id"
    t.boolean "is_alive"
    t.datetime "creation_date"
    t.index ["character_id"], name: "index_user_characters_on_character_id"
    t.index ["user_id"], name: "index_user_characters_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "nickname"
    t.string "email"
    t.string "password"
    t.integer "health"
    t.integer "level"
    t.integer "experience"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
  end

  add_foreign_key "friendships", "users"
  add_foreign_key "group_requests", "groups"
  add_foreign_key "group_requests", "users"
  add_foreign_key "habits", "groups", on_delete: :cascade
  add_foreign_key "habits", "users"
  add_foreign_key "memberships", "groups"
  add_foreign_key "memberships", "users"
  add_foreign_key "notifications", "group_requests", on_delete: :cascade
  add_foreign_key "notifications", "groups", on_delete: :cascade
  add_foreign_key "notifications", "requests", on_delete: :cascade
  add_foreign_key "notifications", "track_individual_habits", on_delete: :cascade
  add_foreign_key "requests", "users"
  add_foreign_key "track_group_habits", "habits", on_delete: :cascade
  add_foreign_key "track_group_habits", "users"
  add_foreign_key "track_individual_habits", "habits"
  add_foreign_key "types", "groups"
  add_foreign_key "types", "users"
  add_foreign_key "user_characters", "characters"
  add_foreign_key "user_characters", "users"
end
