class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :name, :null => false
      t.references :account_type, :null => false

      t.timestamps
    end
  end
end
