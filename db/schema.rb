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

ActiveRecord::Schema.define(version: 20151007003134) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "followers", id: false, force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "grocery_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "followers", ["grocery_id"], name: "index_followers_on_grocery_id", using: :btree
  add_index "followers", ["user_id"], name: "index_followers_on_user_id", using: :btree

  create_table "groceries", force: :cascade do |t|
    t.string   "name"
    t.string   "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "groceries_users", id: false, force: :cascade do |t|
    t.integer "grocery_id"
    t.integer "user_id"
  end

  add_index "groceries_users", ["grocery_id"], name: "index_groceries_users_on_grocery_id", using: :btree
  add_index "groceries_users", ["user_id"], name: "index_groceries_users_on_user_id", using: :btree

  create_table "privileges", id: false, force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "grocery_id"
    t.integer  "privilege"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "privileges", ["grocery_id"], name: "index_privileges_on_grocery_id", using: :btree
  add_index "privileges", ["user_id"], name: "index_privileges_on_user_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.float    "stock"
    t.integer  "unit"
    t.integer  "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "grocery_id"
  end

  add_index "products", ["grocery_id"], name: "index_products_on_grocery_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "username"
    t.string   "password"
    t.string   "password_confirmation"
    t.string   "email"
    t.string   "address"
    t.string   "remember_token"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree

  add_foreign_key "products", "groceries"
end
