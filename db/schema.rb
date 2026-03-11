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

ActiveRecord::Schema[7.2].define(version: 2026_03_11_094410) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "convictions", force: :cascade do |t|
    t.bigint "politician_id", null: false
    t.date "conviction_date", null: false
    t.string "offense_type", null: false
    t.string "sentence_prison"
    t.decimal "sentence_fine", precision: 10, scale: 2
    t.string "sentence_ineligibility"
    t.string "appeal_status", null: false
    t.text "description"
    t.string "source_url", null: false
    t.boolean "verified", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appeal_status"], name: "index_convictions_on_appeal_status"
    t.index ["conviction_date"], name: "index_convictions_on_conviction_date"
    t.index ["offense_type"], name: "index_convictions_on_offense_type"
    t.index ["politician_id"], name: "index_convictions_on_politician_id"
  end

  create_table "politicians", force: :cascade do |t|
    t.string "name", null: false
    t.string "party", null: false
    t.string "photo_url"
    t.string "position", null: false
    t.string "wikipedia_url"
    t.boolean "active", default: true
    t.jsonb "hemicycle_position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_politicians_on_name"
    t.index ["party"], name: "index_politicians_on_party"
    t.index ["position"], name: "index_politicians_on_position"
  end

  add_foreign_key "convictions", "politicians"
end
