class CreateConvictions < ActiveRecord::Migration[7.2]
  def change
    create_table :convictions do |t|
      t.references :politician, null: false, foreign_key: true
      t.date :conviction_date, null: false
      t.string :offense_type, null: false
      t.string :sentence_prison
      t.decimal :sentence_fine, precision: 10, scale: 2
      t.string :sentence_ineligibility
      t.string :appeal_status, null: false
      t.text :description
      t.string :source_url, null: false
      t.boolean :verified, default: false

      t.timestamps
    end

    add_index :convictions, :conviction_date
    add_index :convictions, :offense_type
    add_index :convictions, :appeal_status
  end
end
