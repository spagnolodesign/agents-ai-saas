class CreateBookings < ActiveRecord::Migration[7.2]
  def change
    create_table :bookings do |t|
      t.references :brand, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.string :service_type
      t.date :date
      t.datetime :time
      t.string :status
      t.text :notes
      t.jsonb :metadata

      t.timestamps
    end

    add_index :bookings, [:brand_id, :customer_id]
    add_index :bookings, [:brand_id, :status]
    add_index :bookings, [:brand_id, :date]
  end
end
