class Entry < ActiveRecord::Base
  belongs_to :sheet

  CATEGORIES = ['Others', 'Airtime', 'Transfers', 'Withdrawals', 'Commissions', 'Refunds', 'Deposits']

  def credit?
    self.transaction_type == true
  end

  def debit?
    self.transaction_type == false
  end

end
