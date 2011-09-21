require 'spec_helper'

describe Transaction do

  it 'should have an amount'
  it 'should have an debit account'
  it 'should have an credit account'
  
  # 'locked' is a user-settable flag, anytime
  describe 'when locked' do
    it 'should not be possible to change the amount'
    it 'should not be possible to change the date'
    it 'should not be possible to change the transaction text'
    it 'should not be possible to change the debit account'
    it 'should not be possible to change the credit account'
    it 'should not be possible to change the transaction notes'
    it 'should not be possible to reconcile the transaction'

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
