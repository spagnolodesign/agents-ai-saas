class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.references :brand, null: false, foreign_key: true
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :role

      t.timestamps
    end

    # Email unique per brand (tenant-scoped uniqueness)
    add_index :users, [ :brand_id, :email ], unique: true
  end
end
