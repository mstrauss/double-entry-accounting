class Account < ActiveRecord::Base
  belongs_to :account_type
  has_many :transactions, :class_name => 'AccountTransaction'
  
  def saldo
    self.transactions.find(:last, :order => [:date,:transaction_id]).saldo
  end
  
end
