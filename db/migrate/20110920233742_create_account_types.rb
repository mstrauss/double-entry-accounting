class CreateAccountTypes < ActiveRecord::Migration
  def change
    create_table :account_types do |t|
      t.string :name, :null => false

      t.timestamps
    end
  end
end
