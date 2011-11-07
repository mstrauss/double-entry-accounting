class Account < ActiveRecord::Base
  belongs_to :account_type
  has_many :transactions, :class_name => 'AccountTransaction'
  
  def saldo
    t = self.transactions.find(:last, :order => [:date,:transaction_id])
    t.nil? ? 0 : t.saldo
  end
  
end
