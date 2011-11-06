class Transaction < ActiveRecord::Base
  include Importer
  belongs_to :debit_account, :class_name => 'Account'
  belongs_to :credit_account, :class_name => 'Account'

  def merge_attributes_on_import(import, attributes)
    debit_account  = Account.find(:first, :conditions => {:name => attributes['debit_account']})
    throw "Debit account invalid: #{attributes.inspect}" if debit_account.nil?
    credit_account = Account.find(:first, :conditions => {:name => attributes['credit_account']})
    throw "Credit account invalid: #{attributes.inspect}" if credit_account.nil?

    attributes[:debit_account]  = debit_account
    attributes[:credit_account] = credit_account
    self.attributes  = attributes
    # self.imported_at = Time.now
  end

end
