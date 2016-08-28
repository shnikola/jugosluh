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

ActiveRecord::Schema.define(version: 20160827211521) do

  create_table "album_issues", force: :cascade do |t|
    t.integer  "album_id",   limit: 4
    t.integer  "user_id",    limit: 4
    t.text     "message",    limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "albums", force: :cascade do |t|
    t.string  "label",              limit: 255
    t.string  "catnum",             limit: 255
    t.integer "year",               limit: 4
    t.string  "artist",             limit: 500
    t.string  "title",              limit: 500
    t.string  "duplicate_of_id",    limit: 255
    t.string  "discogs_release_id", limit: 255
    t.string  "discogs_master_id",  limit: 255
    t.string  "info_url",           limit: 700
    t.string  "download_url",       limit: 255
    t.string  "image_url",          limit: 255
    t.boolean "in_yu"
    t.integer "track_count",        limit: 4
    t.integer "drive_id",           limit: 4
    t.float   "average_rating",     limit: 24
    t.string  "discogs_catnum",     limit: 255
    t.text    "tracklist",          limit: 65535
  end

  add_index "albums", ["catnum"], name: "index_albums_on_catnum", using: :btree
  add_index "albums", ["discogs_release_id"], name: "index_albums_on_discogs_release_id", using: :btree

  create_table "sources", force: :cascade do |t|
    t.string   "artist",       limit: 255
    t.string   "title",        limit: 255
    t.string   "catnum",       limit: 255
    t.text     "details",      limit: 65535
    t.string   "download_url", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "album_id",     limit: 4
    t.integer  "status",       limit: 4,     default: 0
    t.string   "origin_site",  limit: 255
  end

  create_table "unconfirmed_sources", id: false, force: :cascade do |t|
    t.integer  "id",           limit: 4,     default: 0, null: false
    t.string   "artist",       limit: 255
    t.string   "title",        limit: 255
    t.string   "catnum",       limit: 255
    t.text     "details",      limit: 65535
    t.string   "download_url", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "album_id",     limit: 4
    t.integer  "status",       limit: 4,     default: 0
    t.string   "origin_site",  limit: 255
  end

  create_table "unrecognized_sources", id: false, force: :cascade do |t|
    t.integer  "id",           limit: 4,     default: 0, null: false
    t.string   "artist",       limit: 255
    t.string   "title",        limit: 255
    t.string   "catnum",       limit: 255
    t.text     "details",      limit: 65535
    t.string   "download_url", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "album_id",     limit: 4
    t.integer  "status",       limit: 4,     default: 0
    t.string   "origin_site",  limit: 255
  end

  create_table "user_list_albums", force: :cascade do |t|
    t.integer  "user_list_id", limit: 4
    t.integer  "album_id",     limit: 4
    t.text     "note",         limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_lists", force: :cascade do |t|
    t.integer  "user_id",                limit: 4
    t.string   "name",                   limit: 255
    t.integer  "user_list_albums_count", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_ratings", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "album_id",   limit: 4
    t.integer  "rating",     limit: 4
    t.text     "comment",    limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_ratings", ["album_id"], name: "index_user_ratings_on_album_id", using: :btree
  add_index "user_ratings", ["user_id"], name: "index_user_ratings_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",                   limit: 255
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
