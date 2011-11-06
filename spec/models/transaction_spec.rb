require 'spec_helper'

def good_account
  return @good_account if @good_account
  @good_account = Account.new(
    :name => 'good account',
    :account_type_id => 1 )
  @good_account.save!
  @good_account
end

def good_account_id
  good_account[:id]
end

def another_good_account
  return @another_good_account if @another_good_account
  @another_good_account = Account.new(
    :name => 'another good account',
    :account_type_id => 2 )
  @another_good_account.save!
  @another_good_account
end

def another_good_account_id
  another_good_account[:id]
end

def bad_account_id
  Account.find(:last, :select => 'id', :order => 'id')[:id] + 1
end

def valid_transaction
  { :date => Date.today,
    :amount => 12.345,
    :debit_account_id => good_account_id,
    :credit_account_id => another_good_account_id,
    :text => 'transaction text' }
end

def test_for_db_error( error_message, &block )
  lambda{ yield }.should raise_error(ActiveRecord::StatementInvalid, error_message) 
  # assert !something_else_threw, "There is an error in our test code"
  # assert database_threw && !something_else_threw, error_message
end

def db_should_not_allow_nil_for_attribute( name )
  test_for_db_error( /null value in column "#{name}" violates not-null constraint/ ) do
    @t.update_attribute( name, nil )
  end
end

def db_should_not_allow_update_attribute( name, value )
  test_for_db_error( /This record is (locked|reconciled) and does not allow updating '#{name}'/ ) do
    @t.update_attribute( name, value )
  end
end

shared_examples_for 'any locked or reconciled transaction' do
  it 'should not be possible to change the amount' do
    db_should_not_allow_update_attribute( :amount, 99 ) end
  it 'should not be possible to change the date' do
    db_should_not_allow_update_attribute( :date, Date.today - 5.days ) end
  it 'should not be possible to change the transaction text' do
    db_should_not_allow_update_attribute( :text, 'new transaction text' ) end
  it 'should not be possible to change the debit account' do
    db_should_not_allow_update_attribute( :debit_account_id, 123 ) end
  it 'should not be possible to change the credit account' do
    db_should_not_allow_update_attribute( :credit_account_id, 123 ) end
end

describe Transaction do

  before(:each) do
    @t = Transaction.new( valid_transaction )
  end

  describe 'save whole record at once' do
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
  
  describe 'saving a single attribute' do
    before(:each) do
      @t.save!
      @t.reload
    end
    it 'should fail on nil date' do
      db_should_not_allow_nil_for_attribute( :date ) end
    it 'should fail on nil amount' do
      db_should_not_allow_nil_for_attribute( :amount ) end
    it 'should fail on nil debit account' do
      db_should_not_allow_nil_for_attribute( :debit_account_id ) end
    it 'should fail on nil credit account' do
      db_should_not_allow_nil_for_attribute( :credit_account_id ) end
    it 'should fail on nil text' do
      db_should_not_allow_nil_for_attribute( :text ) end
    it 'should not fail on nil notes' do
      @t.update_attribute( :notes, nil ).should == true end
  end
  
  
  # 'locked' is a user-settable flag, anytime
  describe 'when locked' do

    before(:each) do
      @t.locked = true
      @t.save!
      @t.reload
    end

    it_behaves_like 'any locked or reconciled transaction'

    it 'should not be possible to change the transaction notes' do
      db_should_not_allow_update_attribute( :notes, 'some new notes' ) end      

    it 'should not be possible to reconcile the transaction' do
      db_should_not_allow_update_attribute( :reconciled, true ) end      

    it 'should set the locked_at datetime when locked' do
      @t.locked_at.to_i.should == DateTime.now.to_i
    end      
    it 'should reset the locked_at datetime when unlocked' do
      @t.update_attribute( :locked, false )
      # @t.reload
      @t.locked_at.should == nil
    end
    
    it 'should be unlockable' do
      @t.update_attribute( :locked, false ).should == true
    end
  end

  # 'reconciled' may be set once, but never reset
  describe 'when reconciled' do
    
    before(:each) do
      @t.reconciled = true
      @t.save!
      @t.reload
    end
    
    it_behaves_like 'any locked or reconciled transaction'
    
    it 'should set the reconciled_at datetime when reconciled' do
      @t.reconciled_at.to_i.should == DateTime.now.to_i
    end
    
    it 'should not be possibe to reset the reconciled flag' do
      test_for_db_error( /It is not possible to unreconcile a transaction after it has been reconciled/ ) do
        @t.update_attribute( :reconciled, false )
      end
    end
    
    it 'should become locked when it gets reconciled' do
      @t.locked.should == true
    end
  end

  def on_update_and_reload_amount_should_remain_unchanged( amount )
    @t.update_attribute( :amount, amount )
    @t.save!
    @t.reload
    @t.amount.should == BigDecimal.new(amount)
  end

  it 'should save all significant decimal places of the amount' do
    on_update_and_reload_amount_should_remain_unchanged( '12.345' )
    on_update_and_reload_amount_should_remain_unchanged( '123456789.123' )
    on_update_and_reload_amount_should_remain_unchanged( '12345.6789' )
    on_update_and_reload_amount_should_remain_unchanged( '1234567890123.998877665544' )
  end
  
  # referencial integrity
  it 'must allow only existing debit account ids' do
    test_for_db_error( /violates foreign key constraint/ ) do
      @t.update_attribute( :debit_account_id, bad_account_id )
    end
    @t.update_attribute( :debit_account_id, good_account_id )
  end
  
  it 'must allow only existing credit account ids' do
    test_for_db_error( /violates foreign key constraint/ ) do
      @t.update_attribute( :credit_account_id, bad_account_id )
    end
    @t.update_attribute( :credit_account_id, another_good_account_id )
  end

  it 'must not allow identical credit and debit accounts' do
    test_for_db_error( /Debit and credit accounts cannot be identical/ ) do
      @t.update_attribute( :credit_account_id, good_account_id )
      @t.update_attribute( :debit_account_id, good_account_id )
    end
  end
  
  # rails helpers for referential integrity
  it 'must have accessible debit_account' do
    @t.debit_account
  end

  it 'must have accessible credit_account' do
    @t.credit_account
  end
  
end
