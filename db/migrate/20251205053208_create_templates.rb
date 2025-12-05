class CreateTemplates < ActiveRecord::Migration[7.2]
  def change
    create_table :templates do |t|
      t.string :name
      t.text :base_prompt
      t.jsonb :workflow_definition

      t.timestamps
    end
  end
end
