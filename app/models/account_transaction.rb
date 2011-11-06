class AccountTransaction < ActiveRecord::Base
  has_many :accounts
end
