require 'spec_helper'

def valid_account
  accounts(:cash_account)
end

def account_transaction
  valid_account.transactions.first
end

describe Account do

  fixtures :accounts, :transactions
  
  it 'should always be one of the four account types'
  it 'should not be possible to delete the account if it has any transactions'
  
  it 'should be an AccountTransaction' do
    account_transaction.class.should == AccountTransaction
  end
  
  describe 'AccountTransaction' do
    it 'should include the date' do
      account_transaction.respond_to?(:date).should== true
    end
    it 'should include the text' do
      account_transaction.respond_to?(:text).should== true
    end
    it 'should include a debit (X)OR credit amount' do
      account_transaction.respond_to?(:debit_amount).should== true
      account_transaction.respond_to?(:credit_amount).should== true
      ( account_transaction.credit_amount == 0 or
        account_transaction.debit_amount  == 0 ).should== true
      ( account_transaction.credit_amount != 0 or
        account_transaction.debit_amount  != 0 ).should== true
    end
  end

end
