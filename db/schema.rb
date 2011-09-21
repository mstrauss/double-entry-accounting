# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110921043139) do

  create_table "account_types", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounts", :force => true do |t|
    t.string   "name",            :null => false
    t.integer  "account_type_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transactions", :force => true do |t|
    t.date     "date",                                 :null => false
    t.integer  "debit_account_id",                     :null => false
    t.integer  "credit_account_id",                    :null => false
    t.decimal  "amount",                               :null => false
    t.string   "text",                                 :null => false
    t.text     "notes"
    t.boolean  "locked",            :default => false, :null => false
    t.datetime "locked_at"
    t.boolean  "reconciled",        :default => false, :null => false
    t.datetime "reconciled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "transactions", ["amount"], :name => "index_transactions_on_amount"
  add_index "transactions", ["credit_account_id"], :name => "index_transactions_on_credit_account_id"
  add_index "transactions", ["date"], :name => "index_transactions_on_date"
  add_index "transactions", ["debit_account_id"], :name => "index_transactions_on_debit_account_id"
  add_index "transactions", ["text"], :name => "index_transactions_on_text"

end
