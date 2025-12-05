class CreatePayments < ActiveRecord::Migration[7.2]
  def change
    create_table :payments do |t|
      t.references :brand, null: false, foreign_key: true
      t.references :booking, null: false, foreign_key: true
      t.string :stripe_payment_intent_id
      t.string :stripe_checkout_session_id
      t.decimal :amount, precision: 10, scale: 2
      t.string :currency, default: "eur"
      t.string :status
      t.string :payment_url
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :payments, [ :brand_id, :booking_id ]
    add_index :payments, [ :brand_id, :stripe_payment_intent_id ]
    add_index :payments, [ :brand_id, :status ]
  end
end
