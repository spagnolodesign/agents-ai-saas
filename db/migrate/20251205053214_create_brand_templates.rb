class CreateBrandTemplates < ActiveRecord::Migration[7.2]
  def change
    create_table :brand_templates do |t|
      t.references :brand, null: false, foreign_key: true
      t.references :template, null: false, foreign_key: true
      t.text :custom_prompt
      t.jsonb :overrides

      t.timestamps
    end

    add_index :brand_templates, [ :brand_id, :template_id ], unique: true
  end
end
