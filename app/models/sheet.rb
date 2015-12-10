class Numeric
  def percent_of(n)
    self.to_f / n.to_f * 100.0
  end
end


class Sheet < ActiveRecord::Base
	before_create :randomize_id
	has_many :rows, :dependent => :destroy
  has_many :entries,:primary_key => :token, :dependent => :delete_all
	self.primary_key = 'token'

	def get_weekly_summary
		weekly_transactions = entries.group_by {|x| x.date.beginning_of_week }
		summary = []
		weekly_transactions.each do |date, transactions|
			week_summary = {}
			income = transactions.select {|transaction| transaction.credit? }.sum(&:amount).round(2)
			expense = transactions.select {|transaction| transaction.debit? }.sum(&:amount).round(2)
			week_summary[:week] = Date::MONTHNAMES[date.at_beginning_of_week.month] + ' ' + date.at_beginning_of_week.strftime('%d') + ' - ' + Date::MONTHNAMES[date.at_end_of_week.month] + ' ' + date.at_end_of_week.strftime('%d')
			week_summary[:year] = date.year.to_s
			week_summary[:income] = income
			week_summary[:expense] = expense
			week_summary[:savings] = (income - expense).round(2)
			week_summary[:opening] = transactions.first.balance

			summary << week_summary
		end
		summary
	end

	def get_monthly_summary
		monthly_transactions = entries.group_by {|x| x.date.beginning_of_month }
		puts monthly_transactions
		summary = []
		if monthly_transactions.count <= 2
			return self.get_weekly_summary
		end
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
			transaction_type = index > 4 ? 1 : 0; # Last two categories are credit categories
			transactions_in_category = entries.where({tag: index, transaction_type: transaction_type})
			category = {}
			category[:type] = transaction_type == 1 ? "credit" : "debit";
			category[:name] = Entry::CATEGORIES[index]
			category[:percent] = transactions_in_category.count.percent_of(no_of_transactions).round(2)
			category[:amount] = transactions_in_category.sum(:amount).round(2)

			categories << category
		end
		categories
	end

	def get_monthly_comparisons
		monthly_transactions = entries.group_by {|x| x.date.beginning_of_month }
		comparisons = []
		monthly_transactions.each do |date, transactions|
			income = transactions.select {|transaction| transaction.credit? }
			expenses = transactions.select {|transaction| transaction.debit? }
			income_total = income.sum(&:amount).round(2)
			expenses_total = expenses.sum(&:amount).round(2)

			period = {}
			period[:date] = date
			period[:time] = date.strftime("%B, %Y")
			period[:opening_balance] = transactions.first.balance
			period[:expense_total] = expenses_total
			period[:income_total] = income_total
			period[:expenses] = expenses
			period[:income] = income
			period[:transactions] = transactions.count

			comparisons << period
		end
		comparisons
	end

	def search query
    self.entries.where("LOWER(remarks) LIKE LOWER(?)", "%#{query}%")
  	end

	private
	def randomize_id
	  begin
	    self.token = SecureRandom.hex(15)
	  end while Sheet.where(token: self.token).exists?
	end
end
