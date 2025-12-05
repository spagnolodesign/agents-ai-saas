class CreateBrands < ActiveRecord::Migration[7.2]
  def change
    create_table :brands do |t|
      t.string :name
      t.string :subdomain
      t.jsonb :settings

      t.timestamps
    end
    add_index :brands, :subdomain, unique: true
  end
end
