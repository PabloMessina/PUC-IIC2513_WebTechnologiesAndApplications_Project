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

ActiveRecord::Schema.define(version: 20151209010558) do

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

  add_index "followers", ["grocery_id", "user_id"], name: "index_followers_on_grocery_id_and_user_id", unique: true, using: :btree
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

  create_table "inventories", force: :cascade do |t|
    t.decimal  "stock"
    t.integer  "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "inventories", ["product_id"], name: "index_inventories_on_product_id", using: :btree

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
    t.integer  "price"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "grocery_id"
    t.integer  "category_id"
    t.text     "description"
    t.boolean  "visible",     default: true
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

  create_table "report_comments", force: :cascade do |t|
    t.text     "content"
    t.integer  "user_id"
    t.integer  "report_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "report_comments", ["report_id"], name: "index_report_comments_on_report_id", using: :btree
  add_index "report_comments", ["user_id"], name: "index_report_comments_on_user_id", using: :btree

  create_table "reports", force: :cascade do |t|
    t.string   "title"
    t.text     "text"
    t.integer  "grocery_id"
    t.integer  "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
  end

  add_index "reports", ["grocery_id"], name: "index_reports_on_grocery_id", using: :btree
  add_index "reports", ["user_id"], name: "index_reports_on_user_id", using: :btree

  create_table "review_comments", force: :cascade do |t|
    t.text     "content"
    t.integer  "review_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "review_comments", ["review_id"], name: "index_review_comments_on_review_id", using: :btree
  add_index "review_comments", ["user_id"], name: "index_review_comments_on_user_id", using: :btree

  create_table "reviews", force: :cascade do |t|
    t.text     "content"
    t.integer  "product_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "title"
  end

  add_index "reviews", ["product_id", "user_id"], name: "index_reviews_on_product_id_and_user_id", unique: true, using: :btree
  add_index "reviews", ["product_id"], name: "index_reviews_on_product_id", using: :btree
  add_index "reviews", ["user_id"], name: "index_reviews_on_user_id", using: :btree

  create_table "star_counts", force: :cascade do |t|
    t.integer  "one",        default: 0
    t.integer  "two",        default: 0
    t.integer  "three",      default: 0
    t.integer  "four",       default: 0
    t.integer  "five",       default: 0
    t.integer  "product_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "star_counts", ["product_id"], name: "index_star_counts_on_product_id", using: :btree

  create_table "stars", force: :cascade do |t|
    t.integer  "value"
    t.integer  "product_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "stars", ["product_id", "user_id"], name: "index_stars_on_product_id_and_user_id", unique: true, using: :btree
  add_index "stars", ["product_id"], name: "index_stars_on_product_id", using: :btree
  add_index "stars", ["user_id"], name: "index_stars_on_user_id", using: :btree

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
  add_foreign_key "inventories", "products"
  add_foreign_key "order_lines", "purchase_orders"
  add_foreign_key "product_images", "products"
  add_foreign_key "products", "categories"
  add_foreign_key "products", "groceries"
  add_foreign_key "purchase_orders", "groceries"
  add_foreign_key "purchase_orders", "users"
  add_foreign_key "report_comments", "reports"
  add_foreign_key "report_comments", "users"
  add_foreign_key "reports", "groceries"
  add_foreign_key "reports", "products"
  add_foreign_key "reports", "users"
  add_foreign_key "review_comments", "reviews"
  add_foreign_key "review_comments", "users"
  add_foreign_key "reviews", "products"
  add_foreign_key "reviews", "users"
  add_foreign_key "star_counts", "products"
  add_foreign_key "stars", "products"
  add_foreign_key "stars", "users"
end
