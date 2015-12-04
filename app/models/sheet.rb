class Numeric
  def percent_of(n)
    self.to_f / n.to_f * 100.0
  end
end


class Sheet < ActiveRecord::Base
	before_create :randomize_id
	has_many :rows, :dependent => :destroy
  has_many :entries,:primary_key => :token, :dependent => :destroy
	self.primary_key = 'token'


	def get_monthly_summary
		monthly_transactions = entries.group_by {|x| x.date.beginning_of_month }
		summary = []
		monthly_transactions.each do |date, transactions|
			month_summary = {}
			income = transactions.select {|transaction| transaction.credit? }.sum(&:amount).round(2)
			expense = transactions.select {|transaction| transaction.debit? }.sum(&:amount).round(2)
			month_summary[:month] = Date::MONTHNAMES[date.month]
			month_summary[:year] = date.year.to_s
			month_summary[:income] = income
			month_summary[:expense] = expense
			month_summary[:savings] = (income - expense).round(2)
			month_summary[:opening] = transactions.first.balance

			summary << month_summary
		end
		summary
	end

	def get_income_amount_and_credits
		credits = entries.select { |transaction| transaction.credit? }
		return credits.count, credits.sum(&:amount)
	end

	def get_expense_amount_and_debits
		debits = entries.select { |transaction| transaction.debit? }
		return debits.count, debits.sum(&:amount)
	end

	def get_categories_data
		categories = []
		no_of_transactions = entries.count
		(0..6).each do |index|
			transactions_in_category = entries.where({tag: index})
			category = {}
			category[:name] = Entry::CATEGORIES[index]
			category[:percent] = transactions_in_category.count.percent_of(no_of_transactions).round(2)
			category[:amount] = transactions_in_category.sum(:amount).round(2)

			categories << category
		end
		categories
	end



	private
	def randomize_id
	  begin
	    self.token = SecureRandom.hex(15)
	  end while Sheet.where(token: self.token).exists?
	end
end
