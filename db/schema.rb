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

ActiveRecord::Schema[7.1].define(version: 2025_05_26_020000) do
  create_table "file_contents", force: :cascade do |t|
    t.integer "file_system_node_id", null: false
    t.string "content_type"
    t.string "storage_type", default: "blob", null: false
    t.binary "blob_data", limit: 16777216
    t.string "s3_key"
    t.text "file_path"
    t.string "checksum"
    t.bigint "content_size", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["checksum"], name: "index_file_contents_on_checksum"
    t.index ["file_path"], name: "index_file_contents_on_file_path", unique: true, where: "file_path IS NOT NULL"
    t.index ["file_system_node_id"], name: "index_file_contents_on_file_system_node_id", unique: true
    t.index ["s3_key"], name: "index_file_contents_on_s3_key", unique: true, where: "s3_key IS NOT NULL"
    t.index ["storage_type"], name: "index_file_contents_on_storage_type"
  end

  create_table "file_system_nodes", force: :cascade do |t|
    t.string "name", null: false
    t.text "path", null: false
    t.string "node_type", null: false
    t.integer "parent_id"
    t.bigint "size", default: 0
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "children_count", default: 0, null: false
    t.index ["children_count"], name: "index_file_system_nodes_on_children_count"
    t.index ["node_type"], name: "index_file_system_nodes_on_node_type"
    t.index ["parent_id", "name"], name: "index_file_system_nodes_on_parent_id_and_name", unique: true
    t.index ["parent_id"], name: "index_file_system_nodes_on_parent_id"
    t.index ["path"], name: "index_file_system_nodes_on_path", unique: true
  end

  add_foreign_key "file_contents", "file_system_nodes"
  add_foreign_key "file_system_nodes", "file_system_nodes", column: "parent_id"
end
