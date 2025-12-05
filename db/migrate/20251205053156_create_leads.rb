class CreateLeads < ActiveRecord::Migration[7.2]
  def change
    create_table :leads do |t|
      t.references :brand, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.string :form_type
      t.string :status

      t.timestamps
    end

    add_index :leads, [ :brand_id, :customer_id ]
    add_index :leads, [ :brand_id, :status ]
  end
end
