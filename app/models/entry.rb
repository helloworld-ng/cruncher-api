class Entry < ActiveRecord::Base
  belongs_to :sheet

  CATEGORIES = ['Others', 'Airtime', 'Transfers', 'Withdrawals', 'Commissions', 'Refunds', 'Deposits']

  def credit?
    self.transaction_type == 1
  end

  def debit?
    self.transaction_type == 0
  end

  def as_json
    {
      date: self.date,
      ref: self.ref,
      transaction_type: if self.credit? then 'credit' else 'debit' end,
      amount: self.amount,
      balance: self.balance,
      remarks: self.remarks,
      category: self.class::CATEGORIES[self.tag],
      sheet_id: self.sheet_id
    }
  end

end
