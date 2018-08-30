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

ActiveRecord::Schema.define(version: 2018_08_30_012023) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "characters", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "habits", force: :cascade do |t|
    t.string "name"
    t.integer "frecuency"
    t.string "difficulty"
    t.boolean "hasEnd"
    t.string "privacy"
    t.date "endDate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "habits_and_categories", primary_key: ["habit_id", "category_id"], force: :cascade do |t|
    t.bigint "habit_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_habits_and_categories_on_category_id"
    t.index ["habit_id"], name: "index_habits_and_categories_on_habit_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "nickname"
    t.string "mail"
    t.string "password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users_and_categories", primary_key: ["user_id", "category_id"], force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_users_and_categories_on_category_id"
    t.index ["user_id"], name: "index_users_and_categories_on_user_id"
  end

  create_table "users_and_characters", primary_key: ["user_id", "character_id"], force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "character_id", null: false
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_users_and_characters_on_character_id"
    t.index ["user_id"], name: "index_users_and_characters_on_user_id"
  end

  create_table "users_and_habits", primary_key: ["user_id", "habit_id"], force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "habit_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["habit_id"], name: "index_users_and_habits_on_habit_id"
    t.index ["user_id"], name: "index_users_and_habits_on_user_id"
  end

  add_foreign_key "habits_and_categories", "categories"
  add_foreign_key "habits_and_categories", "habits"
  add_foreign_key "users_and_categories", "categories"
  add_foreign_key "users_and_categories", "users"
  add_foreign_key "users_and_characters", "characters"
  add_foreign_key "users_and_characters", "users"
  add_foreign_key "users_and_habits", "habits"
  add_foreign_key "users_and_habits", "users"
end
