class Account < ActiveRecord::Base
  belongs_to :account_type
  has_many :transactions, :class_name => 'AccountTransaction'
end
