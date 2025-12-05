class CreateConversations < ActiveRecord::Migration[7.2]
  def change
    create_table :conversations do |t|
      t.references :brand, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.jsonb :messages
      t.string :status
      t.datetime :last_message_at

      t.timestamps
    end

    add_index :conversations, [:brand_id, :customer_id]
    add_index :conversations, [:brand_id, :status]
    add_index :conversations, :last_message_at
  end
end
