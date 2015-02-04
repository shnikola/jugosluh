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

ActiveRecord::Schema.define(version: 20150204041756) do

  create_table "albums", force: true do |t|
    t.string  "label"
    t.string  "catnum"
    t.integer "year"
    t.string  "artist",             limit: 500
    t.string  "title",              limit: 500
    t.string  "duplicate_of_id"
    t.string  "discogs_release_id"
    t.string  "discogs_master_id"
    t.string  "info_url",           limit: 700
    t.string  "download_url"
    t.boolean "in_yu"
    t.boolean "confirmed",                      default: false
    t.integer "tracks"
  end

  add_index "albums", ["catnum"], name: "index_albums_on_catnum", using: :btree
  add_index "albums", ["discogs_release_id"], name: "index_albums_on_discogs_release_id", using: :btree

  create_table "sources", force: true do |t|
    t.string   "artist"
    t.string   "title"
    t.string   "catnum"
    t.text     "details"
    t.string   "download_url"
    t.boolean  "in_yu",                  default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "album_id"
    t.integer  "downloaded",   limit: 1, default: 0
  end

  create_table "user_ratings", force: true do |t|
    t.integer "user_id"
    t.integer "album_id"
    t.integer "rating"
    t.text    "comment"
  end

  add_index "user_ratings", ["album_id"], name: "index_user_ratings_on_album_id", using: :btree
  add_index "user_ratings", ["user_id"], name: "index_user_ratings_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
