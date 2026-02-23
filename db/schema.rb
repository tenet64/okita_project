# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

<<<<<<< HEAD
ActiveRecord::Schema[7.2].define(version: 2026_02_23_130139) do
=======
ActiveRecord::Schema[7.2].define(version: 2026_02_11_132011) do
>>>>>>> 46dc497a9368836cbd3ea1e9dbf1c42aeabd5d09
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "badges", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.text "description", null: false
    t.string "image_path", null: false
    t.string "condition_key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["condition_key"], name: "index_badges_on_condition_key", unique: true
  end

  create_table "challenges", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "title"
    t.integer "mode"
    t.integer "status", default: 0
    t.time "target_time"
    t.date "target_date"
    t.integer "capacity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_challenges_on_user_id"
  end

  create_table "participations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "challenge_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["challenge_id"], name: "index_participations_on_challenge_id"
    t.index ["user_id", "challenge_id"], name: "index_participations_on_user_id_and_challenge_id", unique: true
    t.index ["user_id"], name: "index_participations_on_user_id"
  end

  create_table "point_transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.integer "points", default: 0, null: false
    t.integer "reason", null: false
    t.string "source_type", null: false
    t.uuid "source_id", null: false
    t.date "target_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["source_type", "source_id"], name: "index_point_transactions_on_source"
    t.index ["user_id", "reason", "source_type", "source_id", "target_date"], name: "idx_point_tx_unique_grant", unique: true
    t.index ["user_id"], name: "index_point_transactions_on_user_id"
  end

  create_table "user_badges", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "badge_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["badge_id"], name: "index_user_badges_on_badge_id"
    t.index ["user_id", "badge_id"], name: "index_user_badges_on_user_id_and_badge_id", unique: true
    t.index ["user_id"], name: "index_user_badges_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.integer "total_points"
    t.string "provider"
    t.string "uid"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wake_up_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "challenge_id", null: false
    t.date "target_date"
    t.datetime "pressed_at"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["challenge_id"], name: "index_wake_up_logs_on_challenge_id"
    t.index ["user_id", "challenge_id", "target_date"], name: "index_wake_up_logs_on_user_id_and_challenge_id_and_target_date", unique: true
    t.index ["user_id"], name: "index_wake_up_logs_on_user_id"
  end

  add_foreign_key "challenges", "users"
  add_foreign_key "participations", "challenges"
  add_foreign_key "participations", "users"
  add_foreign_key "point_transactions", "users"
  add_foreign_key "user_badges", "badges"
  add_foreign_key "user_badges", "users"
  add_foreign_key "wake_up_logs", "challenges"
  add_foreign_key "wake_up_logs", "users"
end
