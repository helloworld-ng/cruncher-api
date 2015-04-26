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

ActiveRecord::Schema.define(version: 20150424012542) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "rows", force: :cascade do |t|
    t.datetime "date"
    t.integer  "ref",        limit: 8
    t.integer  "debit"
    t.integer  "credit"
    t.integer  "balance"
    t.string   "remarks"
    t.integer  "sheet_id",   limit: 8
    t.integer  "tag"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "sheets", id: false, force: :cascade do |t|
    t.string   "token",      null: false
    t.string   "name"
    t.string   "address"
    t.string   "account"
    t.datetime "from"
    t.datetime "to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "sheets", ["token"], name: "index_sheets_on_token", unique: true, using: :btree

end
