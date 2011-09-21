require 'spec_helper'

def valid_transaction
  { :date => Date.today,
    :amount => 12.345,
    :debit_account_id => 1,
    :credit_account_id => 2,
    :text => 'transaction text' }
end

def test_for_db_error( error_message, &block )
  begin
    yield
  rescue ActiveRecord::StatementInvalid
    database_threw = true
  rescue
    something_else_threw = true
  end
  assert !something_else_threw, "There is an error in our test code"
  assert database_threw && !something_else_threw, error_message
end

def db_should_not_allow_nil_for_attribute( name )
  t = Transaction.new( valid_transaction )
  test_for_db_error( "Column '#{name}' cannot be null" ) do
    t.update_attribute( name, nil )
    t.save!
  end
end

def when_locked_db_should_not_allow_update_attribute( name, value )
  test_for_db_error( "Column '#{name}' cannot be updated when record is locked") do
    @t.update_attribute( name, value )
  end
end

describe Transaction do

  describe 'save' do
    it 'should fail without date' do
      db_should_not_allow_nil_for_attribute( :date ) end
    it 'should fail without amount' do
      db_should_not_allow_nil_for_attribute( :amount ) end
    it 'should fail without debit account' do
      db_should_not_allow_nil_for_attribute( :debit_account_id ) end
    it 'should fail without credit account' do
      db_should_not_allow_nil_for_attribute( :credit_account_id ) end
    it 'should fail without text' do
      db_should_not_allow_nil_for_attribute( :text ) end
  end
  
  
  # 'locked' is a user-settable flag, anytime
  describe 'when locked' do

    before(:each) do
      @t = Transaction.new( valid_transaction.update( :locked => true) )
      @t.save!
    end

    it 'should not be possible to change the amount' do
      when_locked_db_should_not_allow_update_attribute( :amount, 99 ) end
    it 'should not be possible to change the date' do
      when_locked_db_should_not_allow_update_attribute( :date, Date.today - 5.days ) end
    it 'should not be possible to change the transaction text' do
      when_locked_db_should_not_allow_update_attribute( :text, 'new transaction text' ) end
    it 'should not be possible to change the debit account' do
      when_locked_db_should_not_allow_update_attribute( :debit_account_id, 123 ) end
    it 'should not be possible to change the credit account' do
      when_locked_db_should_not_allow_update_attribute( :credit_account_id, 123 ) end
    it 'should not be possible to change the transaction notes' do
      when_locked_db_should_not_allow_update_attribute( :notes, 'some new notes' ) end      
    it 'should not be possible to reconcile the transaction' do
      when_locked_db_should_not_allow_update_attribute( :reconciled, true ) end      

    it 'should set the locked_at datetime when locked'
    it 'should reset the locked_at datetime when unlocked'
    
    it 'should be unlockable'
  end

  # 'reconciled' may be set once, but never reset
  describe 'when reconciled' do
    it 'should not be possible to change the amount'
    it 'should not be possible to change the date'
    it 'should not be possible to change the transaction text'
    it 'should not be possible to change the debit account'
    it 'should not be possible to change the credit account'
    it 'should be possible to change the transaction notes'
    
    it 'should set the reconciled_at datetime when reconciled'
    it 'should not be possibe to reset the reconciled flag'
    
    it 'should become locked when it gets reconciled'
  end

  it 'should save 3 significant decimal places of the amount'
  
end
