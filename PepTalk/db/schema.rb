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

ActiveRecord::Schema[8.0].define(version: 2025_10_12_001000) do
  create_table "posts", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "owner"
    t.string "recipient"
    t.text "shareLink"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "share_links", force: :cascade do |t|
    t.string "token", null: false
    t.integer "post_id", null: false
    t.integer "user_id"
    t.string "permissions", default: "read", null: false
    t.datetime "expires_at"
    t.datetime "revoked_at"
    t.integer "access_count", default: 0, null: false
    t.datetime "last_accessed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_share_links_on_expires_at"
    t.index ["post_id"], name: "index_share_links_on_post_id"
    t.index ["token"], name: "index_share_links_on_token", unique: true
    t.index ["user_id"], name: "index_share_links_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "mobile_number"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "share_links", "posts"
  add_foreign_key "share_links", "users"
end
