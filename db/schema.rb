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

ActiveRecord::Schema.define(version: 2018_09_01_192429) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "characters", force: :cascade do |t|
    t.string "name"
    t.string "description"
  end

  create_table "group_habit_has_types", primary_key: ["group_habit_id", "type_id"], force: :cascade do |t|
    t.bigint "group_habit_id", null: false
    t.bigint "type_id", null: false
    t.index ["group_habit_id"], name: "index_group_habit_has_types_on_group_habit_id"
    t.index ["type_id"], name: "index_group_habit_has_types_on_type_id"
  end

  create_table "group_habits", primary_key: ["id", "group_id"], force: :cascade do |t|
    t.serial "id", null: false
    t.bigint "group_id", null: false
    t.string "name"
    t.string "description"
    t.integer "dificulty"
    t.integer "privacy"
    t.integer "frecuency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_group_habits_on_group_id"
    t.index ["id"], name: "index_group_habits_on_id"
  end

  create_table "group_types", primary_key: ["type_id", "group_id"], force: :cascade do |t|
    t.bigint "type_id", null: false
    t.bigint "group_id", null: false
    t.index ["group_id"], name: "index_group_types_on_group_id"
    t.index ["type_id"], name: "index_group_types_on_type_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "individual_habit_has_types", primary_key: ["individual_habit_id", "type_id"], force: :cascade do |t|
    t.bigint "individual_habit_id", null: false
    t.bigint "type_id", null: false
    t.index ["individual_habit_id"], name: "index_individual_habit_has_types_on_individual_habit_id"
    t.index ["type_id"], name: "index_individual_habit_has_types_on_type_id"
  end

  create_table "individual_habits", primary_key: ["id", "user_id"], force: :cascade do |t|
    t.bigserial "id", null: false
    t.bigint "user_id", null: false
    t.string "name"
    t.string "description"
    t.integer "dificulty"
    t.integer "privacy"
    t.integer "frecuency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_individual_habits_on_id"
    t.index ["user_id"], name: "index_individual_habits_on_user_id"
  end

  create_table "individual_types", primary_key: ["type_id", "user_id"], force: :cascade do |t|
    t.bigint "type_id", null: false
    t.bigint "user_id", null: false
    t.index ["type_id"], name: "index_individual_types_on_type_id"
    t.index ["user_id"], name: "index_individual_types_on_user_id"
  end

  create_table "track_group_habits", primary_key: ["user_id", "group_habit_id", "date"], force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "group_habit_id", null: false
    t.datetime "date", null: false
    t.index ["group_habit_id"], name: "index_track_group_habits_on_group_habit_id"
    t.index ["user_id"], name: "index_track_group_habits_on_user_id"
  end

  create_table "track_individual_habits", primary_key: ["individual_habit_id", "date"], force: :cascade do |t|
    t.integer "individual_habit_id", null: false
    t.datetime "date", null: false
    t.index ["individual_habit_id"], name: "index_track_individual_habits_on_individual_habit_id"
  end

  create_table "types", force: :cascade do |t|
    t.string "name"
    t.string "description"
  end

  create_table "user_characters", primary_key: ["user_id", "character_id"], force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "character_id", null: false
    t.boolean "is_alive"
    t.datetime "creation_date"
    t.index ["character_id"], name: "index_user_characters_on_character_id"
    t.index ["user_id"], name: "index_user_characters_on_user_id"
  end

  create_table "user_groups", primary_key: ["user_id", "group_id"], force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_user_groups_on_group_id"
    t.index ["user_id"], name: "index_user_groups_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "nickname"
    t.string "mail"
    t.string "password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
  end

  add_foreign_key "group_habits", "groups"
  add_foreign_key "group_types", "groups"
  add_foreign_key "group_types", "types"
  add_foreign_key "individual_habits", "users"
  add_foreign_key "individual_types", "types"
  add_foreign_key "individual_types", "users"
  add_foreign_key "track_group_habits", "users"
  add_foreign_key "user_characters", "characters"
  add_foreign_key "user_characters", "users"
  add_foreign_key "user_groups", "groups"
  add_foreign_key "user_groups", "users"
end
