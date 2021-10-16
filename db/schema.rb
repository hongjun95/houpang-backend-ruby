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

ActiveRecord::Schema.define(version: 2021_10_16_001118) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.string "title"
    t.string "image"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "coverImg"
    t.index ["title"], name: "index_categories_on_title", unique: true
  end

  create_table "images", force: :cascade do |t|
    t.string "imagable_type"
    t.bigint "imagable_id"
    t.string "image"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["imagable_type", "imagable_id"], name: "index_images_on_imagable_type_and_imagable_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "name"
    t.integer "sale_price"
    t.integer "list_price"
    t.text "video"
    t.text "description"
    t.string "image"
    t.integer "status", default: 0
    t.decimal "reviews_average", default: "0.0"
    t.integer "reviews_count"
    t.integer "view_count", default: 0
    t.string "zipcode"
    t.string "address1"
    t.string "address2"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer "_type"
    t.decimal "lat", precision: 15, scale: 10
    t.decimal "lng", precision: 15, scale: 10
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "stock"
    t.string "images", array: true
    t.float "avgRating"
    t.json "infos", array: true
    t.string "product_images", array: true
    t.bigint "user_id", null: false
    t.bigint "category_id", null: false
    t.index ["category_id"], name: "index_items_on_category_id"
    t.index ["images"], name: "index_items_on_images", using: :gin
    t.index ["product_images"], name: "index_items_on_product_images", using: :gin
    t.index ["user_id"], name: "index_items_on_user_id"
  end

  create_table "items_likes", id: false, force: :cascade do |t|
    t.bigint "like_id", null: false
    t.bigint "item_id", null: false
    t.index ["item_id"], name: "index_items_likes_on_item_id"
    t.index ["like_id"], name: "index_items_likes_on_like_id"
  end

  create_table "likes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "count", default: 1
    t.integer "status", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "order_id"
    t.bigint "item_id", null: false
    t.index ["item_id"], name: "index_order_items_on_item_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["user_id"], name: "index_order_items_on_user_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "total"
    t.string "destination"
    t.string "deliver_request"
    t.string "ordered_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "refunds", force: :cascade do |t|
    t.integer "count"
    t.integer "status", default: 0
    t.string "refunded_at"
    t.string "problem_title"
    t.string "problem_description"
    t.string "recall_place"
    t.datetime "recall_day"
    t.string "recall_title"
    t.string "recall_description"
    t.string "send_place"
    t.datetime "send_day"
    t.integer "refund_pay"
    t.bigint "order_item_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id", null: false
    t.index ["order_item_id"], name: "index_refunds_on_order_item_id"
    t.index ["user_id"], name: "index_refunds_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "name", default: ""
    t.string "phone"
    t.string "image"
    t.string "address1"
    t.string "address2"
    t.string "zipcode"
    t.integer "gender", limit: 2, default: 0
    t.date "birthday"
    t.integer "status", limit: 2, default: 0
    t.string "customs_number"
    t.boolean "accept_sms"
    t.boolean "accept_email"
    t.integer "user_type", limit: 2, default: 0
    t.decimal "lat", precision: 15, scale: 10
    t.decimal "lng", precision: 15, scale: 10
    t.string "en_address"
    t.text "description"
    t.integer "point", default: 0
    t.decimal "reviews_average", default: "0.0"
    t.integer "reviews_count"
    t.string "uid"
    t.string "provider"
    t.string "device_token"
    t.string "device_type"
    t.string "link"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "role", default: 0
    t.string "user_img"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "items", "categories"
  add_foreign_key "items", "users"
  add_foreign_key "likes", "users"
  add_foreign_key "order_items", "items"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "users"
  add_foreign_key "orders", "users"
  add_foreign_key "refunds", "order_items"
  add_foreign_key "refunds", "users"
end
