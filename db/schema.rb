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

ActiveRecord::Schema[7.2].define(version: 2026_03_11_093659) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
end
