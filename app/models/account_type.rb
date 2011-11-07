class AccountType < ActiveRecord::Base
  has_many :accounts

  def saldo
    self.accounts.inject(0) { |s,a| s += a.saldo }
  end
  
end
