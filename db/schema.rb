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

ActiveRecord::Schema.define(version: 2022_10_07_220032) do

  create_table "album_issues", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "album_id"
    t.integer "user_id"
    t.text "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "album_sets", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "album_ids"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "intro"
    t.text "albums_json"
  end

  create_table "albums", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "label"
    t.string "catnum"
    t.integer "year"
    t.string "artist", limit: 500
    t.string "title", limit: 500
    t.integer "discogs_release_id"
    t.string "info_url", limit: 700
    t.string "download_url"
    t.string "image_url"
    t.integer "track_count"
    t.integer "drive_id"
    t.float "average_rating"
    t.text "tracklist"
    t.string "spotify_id"
    t.index ["catnum"], name: "index_albums_on_catnum"
    t.index ["discogs_release_id"], name: "index_albums_on_discogs_release_id"
  end

  create_table "discogs_releases", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.string "title", limit: 1000
    t.string "labels", limit: 500
    t.string "catno"
    t.integer "year"
    t.string "cover_image"
    t.string "discogs_master_id"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discogs_master_id"], name: "index_discogs_releases_on_discogs_master_id"
  end

  create_table "sources", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "artist"
    t.string "title"
    t.string "catnum"
    t.text "details"
    t.string "download_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "album_id"
    t.integer "status", default: 0
    t.string "origin_site"
  end

  create_table "user_list_albums", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_list_id"
    t.integer "album_id"
    t.text "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_lists", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.integer "user_list_albums_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_ratings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "album_id"
    t.integer "rating"
    t.text "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["album_id"], name: "index_user_ratings_on_album_id"
    t.index ["user_id"], name: "index_user_ratings_on_user_id"
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "upload_access", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
