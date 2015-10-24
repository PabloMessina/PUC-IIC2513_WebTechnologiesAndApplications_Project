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

ActiveRecord::Schema.define(version: 20151023230158) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

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

  add_index "groceries", ["name"], name: "index_groceries_on_name", unique: true, using: :btree

  create_table "groceries_users", id: false, force: :cascade do |t|
    t.integer "grocery_id"
    t.integer "user_id"
  end

  add_index "groceries_users", ["grocery_id"], name: "index_groceries_users_on_grocery_id", using: :btree
  add_index "groceries_users", ["user_id"], name: "index_groceries_users_on_user_id", using: :btree

  create_table "grocery_images", force: :cascade do |t|
    t.string   "grocery_image"
    t.integer  "grocery_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "grocery_images", ["grocery_id"], name: "index_grocery_images_on_grocery_id", using: :btree

  create_table "order_lines", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "purchase_order_id"
    t.decimal  "amount"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "product_price"
  end

  add_index "order_lines", ["product_id"], name: "index_order_lines_on_product_id", using: :btree
  add_index "order_lines", ["purchase_order_id"], name: "index_order_lines_on_purchase_order_id", using: :btree

  create_table "privileges", id: false, force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "grocery_id"
    t.integer  "privilege",  default: 0
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "privileges", ["grocery_id"], name: "index_privileges_on_grocery_id", using: :btree
  add_index "privileges", ["user_id"], name: "index_privileges_on_user_id", using: :btree

  create_table "product_images", force: :cascade do |t|
    t.string   "product_image"
    t.integer  "product_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "product_images", ["product_id"], name: "index_product_images_on_product_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.decimal  "stock"
    t.integer  "unit"
    t.integer  "price"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "grocery_id"
    t.integer  "category_id"
  end

  add_index "products", ["category_id"], name: "index_products_on_category_id", using: :btree
  add_index "products", ["grocery_id", "name"], name: "index_products_on_grocery_id_and_name", unique: true, using: :btree
  add_index "products", ["grocery_id"], name: "index_products_on_grocery_id", using: :btree

  create_table "products_tags", id: false, force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "tag_id",     null: false
  end

  add_index "products_tags", ["product_id", "tag_id"], name: "index_products_tags_on_product_id_and_tag_id", unique: true, using: :btree
  add_index "products_tags", ["tag_id", "product_id"], name: "index_products_tags_on_tag_id_and_product_id", unique: true, using: :btree

  create_table "purchase_orders", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "grocery_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "purchase_orders", ["grocery_id"], name: "index_purchase_orders_on_grocery_id", using: :btree
  add_index "purchase_orders", ["user_id"], name: "index_purchase_orders_on_user_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_images", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "user_image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "username"
    t.string   "password_digest"
    t.string   "email"
    t.string   "address"
    t.string   "remember_token"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  add_foreign_key "grocery_images", "groceries"
  add_foreign_key "order_lines", "products"
  add_foreign_key "order_lines", "purchase_orders"
  add_foreign_key "product_images", "products"
  add_foreign_key "products", "categories"
  add_foreign_key "products", "groceries"
  add_foreign_key "purchase_orders", "groceries"
  add_foreign_key "purchase_orders", "users"
end
