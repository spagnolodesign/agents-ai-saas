class CreateAnsweredFields < ActiveRecord::Migration[7.2]
  def change
    create_table :answered_fields do |t|
      t.references :lead, null: false, foreign_key: true
      t.string :field_name
      t.string :field_value

      t.timestamps
    end
    # Note: Rails automatically creates index on lead_id via t.references
  end
end
