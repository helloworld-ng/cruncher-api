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

ActiveRecord::Schema.define(version: 20151204083925) do

  create_table "entries", force: :cascade do |t|
    t.datetime "date"
    t.string   "ref"
    t.integer  "transaction_type"
    t.float    "amount"
    t.float    "balance"
    t.string   "remarks"
    t.integer  "tag"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "sheet_id"
  end

  add_index "entries", ["sheet_id"], name: "index_entries_on_sheet_id"

  create_table "rows", force: :cascade do |t|
    t.datetime "date"
    t.integer  "ref",        limit: 8
    t.integer  "debit"
    t.integer  "credit"
    t.integer  "balance"
    t.string   "remarks"
    t.integer  "tag"
    t.string   "sheet_id"
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
    t.string   "bank"
    t.string   "email"
  end

  add_index "sheets", ["token"], name: "index_sheets_on_token", unique: true

end
