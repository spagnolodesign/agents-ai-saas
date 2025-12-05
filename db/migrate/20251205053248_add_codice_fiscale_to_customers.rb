class AddCodiceFiscaleToCustomers < ActiveRecord::Migration[7.2]
  def change
    add_column :customers, :codice_fiscale, :string
    add_index :customers, [ :brand_id, :codice_fiscale ]
  end
end
