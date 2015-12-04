class Entry < ActiveRecord::Base
  belongs_to :sheet

  CATEGORIES = ['Others', 'Airtime', 'Transfers', 'Withdrawals', 'Commissions', 'Refunds', 'Deposits']

  def credit?
    self.transaction_type == 1
  end

  def debit?
    self.transaction_type == 0
  end

end
