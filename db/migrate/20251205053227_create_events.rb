class CreateEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :events do |t|
      t.references :brand, null: false, foreign_key: true
      t.string :event_type
      t.datetime :occurred_at
      t.jsonb :payload

      t.timestamps
    end

    add_index :events, [ :brand_id, :event_type ]
    add_index :events, [ :brand_id, :occurred_at ]
  end
end
