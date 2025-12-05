class CreateWorkflows < ActiveRecord::Migration[7.2]
  def change
    create_table :workflows do |t|
      t.references :brand, null: false, foreign_key: true
      t.string :name
      t.jsonb :steps
      t.boolean :enabled, default: false

      t.timestamps
    end

    add_index :workflows, [:brand_id, :enabled]
  end
end
