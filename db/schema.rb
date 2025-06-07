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

ActiveRecord::Schema[7.1].define(version: 2025_06_07_211009) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "game_session_songs", force: :cascade do |t|
    t.bigint "game_session_id", null: false
    t.bigint "song_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_session_id"], name: "index_game_session_songs_on_game_session_id"
    t.index ["song_id"], name: "index_game_session_songs_on_song_id"
  end

  create_table "game_sessions", force: :cascade do |t|
    t.string "uuid"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "current_stage", default: 0.0
    t.datetime "stage_started_at"
    t.json "stage_data", default: {}
    t.index ["current_stage"], name: "index_game_sessions_on_current_stage"
    t.index ["stage_started_at"], name: "index_game_sessions_on_stage_started_at"
    t.index ["user_id"], name: "index_game_sessions_on_user_id"
  end

  create_table "genre_votes", force: :cascade do |t|
    t.bigint "guest_id", null: false
    t.bigint "genre_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["genre_id"], name: "index_genre_votes_on_genre_id"
    t.index ["guest_id"], name: "index_genre_votes_on_guest_id"
  end

  create_table "genres", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "guests", force: :cascade do |t|
    t.string "nickname"
    t.bigint "game_session_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_session_id"], name: "index_guests_on_game_session_id"
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.text "channel"
    t.text "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "song_votes", force: :cascade do |t|
    t.bigint "guest_id", null: false
    t.integer "votes_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "game_session_song_id", null: false
    t.index ["game_session_song_id"], name: "index_song_votes_on_game_session_song_id"
    t.index ["guest_id"], name: "index_song_votes_on_guest_id"
  end

  create_table "songs", force: :cascade do |t|
    t.string "title"
    t.string "artist"
    t.integer "year"
    t.text "lyrics_lrc"
    t.string "youtube_url"
    t.bigint "genre_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["genre_id"], name: "index_songs_on_genre_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "game_session_songs", "game_sessions"
  add_foreign_key "game_session_songs", "songs"
  add_foreign_key "game_sessions", "users"
  add_foreign_key "genre_votes", "genres"
  add_foreign_key "genre_votes", "guests"
  add_foreign_key "guests", "game_sessions"
  add_foreign_key "song_votes", "game_session_songs"
  add_foreign_key "song_votes", "guests"
  add_foreign_key "songs", "genres"
end
