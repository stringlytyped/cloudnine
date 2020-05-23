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

ActiveRecord::Schema.define(version: 2020_04_24_154431) do

  create_table "locations", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.string "open_weather_id"
    t.integer "utc_offset"
    t.datetime "sunrise"
    t.datetime "sunset"
    t.string "condition_id"
    t.string "condition_description"
    t.string "condition_icon"
    t.float "temperature"
    t.float "feels_like"
    t.float "humidity"
    t.float "wind_speed"
    t.float "cloud_cover"
    t.float "rainfall_1h"
    t.float "rainfall_3h"
    t.float "snowfall_1h"
    t.float "snowfall_3h"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["open_weather_id"], name: "index_locations_on_open_weather_id", unique: true
    t.index ["user_id"], name: "index_locations_on_user_id"
  end

  create_table "mood_ratings", force: :cascade do |t|
    t.integer "user_id"
    t.float "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_mood_ratings_on_user_id"
  end

  create_table "playlists", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.string "spotify_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_playlists_on_user_id", unique: true
  end

  create_table "playlists_tracks", id: false, force: :cascade do |t|
    t.integer "playlist_id"
    t.integer "track_id"
    t.index ["playlist_id"], name: "index_playlists_tracks_on_playlist_id"
    t.index ["track_id"], name: "index_playlists_tracks_on_track_id"
  end

  create_table "tracks", force: :cascade do |t|
    t.string "name"
    t.string "artist"
    t.string "album"
    t.string "image"
    t.string "preview"
    t.float "valence"
    t.string "spotify_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["spotify_id"], name: "index_tracks_on_spotify_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", null: false
    t.string "uid", null: false
    t.string "credentials_json"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

end
