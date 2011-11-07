require 'spec_helper'

def valid_account_type
  AccountType.first
end

describe AccountType do

  it 'should calculate the saldo for its sub-accounts' do
    valid_account_type.respond_to?(:saldo).should == true
  end
  
  describe 'saldo'
  it 'should equal the saldo of all sub-accounts' do
    valid_account_type.saldo.should == -52.5
  end
end
