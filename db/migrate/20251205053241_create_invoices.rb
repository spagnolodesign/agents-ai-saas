class CreateInvoices < ActiveRecord::Migration[7.2]
  def change
    create_table :invoices do |t|
      t.references :brand, null: false, foreign_key: true
      t.references :booking, null: false, foreign_key: true
      t.references :payment, null: false, foreign_key: true
      t.string :number
      t.string :pdf_url
      t.string :status
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :invoices, [ :brand_id, :number ], unique: true
    add_index :invoices, [ :brand_id, :status ]
  end
end
