class CreatePoliticians < ActiveRecord::Migration[7.2]
  def change
    create_table :politicians do |t|
      t.string :name, null: false
      t.string :party, null: false
      t.string :photo_url
      t.string :position, null: false
      t.string :wikipedia_url
      t.boolean :active, default: true
      t.jsonb :hemicycle_position

      t.timestamps
    end

    add_index :politicians, :name
    add_index :politicians, :party
    add_index :politicians, :position
  end
end
