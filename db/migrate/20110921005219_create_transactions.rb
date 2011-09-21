class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.date    :date, :null => false
      t.integer :debit_account_id, :null => false
      t.integer :credit_account_id, :null => false
      t.decimal :amount, :null => false
      t.string  :text, :null => false
      t.text    :notes
      
      # user may lock/unlock the record
      t.boolean  :locked, :default => false, :null => false
      t.datetime :locked_at
      
      # similar to locked, but used in other ways
      t.boolean  :reconciled, :default => false, :null => false
      t.datetime :reconciled_at

      t.timestamps
    end
    
    change_table :transactions do |t|
      # indexes
      t.index :date
      t.index :debit_account_id
      t.index :credit_account_id
      t.index :amount
      t.index :text
    end
  end
end
