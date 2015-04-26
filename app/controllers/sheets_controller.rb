class SheetsController < ApplicationController
  def crunch
    file = params[:file]
    tmp_file = Tempfile.new([file.original_filename, '.xlsx'])
    tmp_file.binmode
    tmp_file.write(file.read)

  	@file = Roo::Excelx.new(tmp_file.path)
    tmp_file.close

  	save_file(@file, params[:email].to_s)
  end

  def details 
    @sheet = Sheet.find(params[:id])
    if @sheet
      render json: @sheet.to_json
    else
      render json: {errors: "Couldn't find the sheet you requested for" }, status: 422
    end
  end

  def transactions
    @transactions = [];
    unless params[:weekly]
      @rows = Sheet.find(params[:id]).rows.group_by { |x| x.date.beginning_of_month }
    else 
      @rows = Sheet.find(params[:id]).rows.group_by { |x| x.date.beginning_of_week }
    end
    @rows.each do |period, values|
      @expenses = values.select { |trans| trans.debit?  }
      @expense_total = @expenses.inject(0) {|sum,e| sum += e.debit } 
      @income = values.select { |trans| trans.credit?  }
      @income_total = @income.inject(0) {|sum,e| sum += e.credit } 

      @period = {
        date: period,
        time: params[:weekly] ? period.strftime("Week %-U, %d %b %y") : period.strftime("%B, %Y"),          
        opening_balance: values[0].balance,
        expense_total: @expense_total, 
        income_total: @income_total,
        expenses: @expenses,
        income: @income,
        transactions: values.length
      }
      @transactions.push(@period)
    end
    render json: @transactions.to_json
  end

  def expenses
    @response = {}
    @transactions = Sheet.find(params[:id]).rows.where({credit: nil})
    @months = @transactions.group_by { |x| x.date.beginning_of_month }
    @weeks = @transactions.group_by { |x| x.date.beginning_of_week }
    @expense_total = @transactions.inject(0) {|sum,e| sum += e.debit }

    @pattern = []
    @months.each do |period, rows|
      m = period.month; y = period.year
      spending = {
        period: period.strftime("%b %Y"),
        total: (rows.inject(0) {|sum,e| sum += e.debit }),
        average: (rows.inject(0) {|sum,e| sum += e.debit }) / (Time::days_in_month(m,y).to_f / 7)
      }
      @pattern.push(spending)
    end

    @transactions = @transactions.where(date: DateTime.strptime(params[:month], '%b %Y').beginning_of_month..DateTime.strptime(params[:month], '%b %Y').end_of_month) if params[:month]

    @response['stats'] = {
      total: @expense_total,
      subtotal: @transactions.inject(0) {|sum,e| sum += e.debit },
      average_month:  @expense_total / @months.length,
      pattern: @pattern
    }

    @airtime = @transactions.where({tag: 1})
    @transfers = @transactions.where({tag: 2})
    @withdrawals = @transactions.where({tag: 3})
    @commissions = @transactions.where({tag: 4})
    @others = @transactions.where({tag: 0})

    @response['types'] = [{
      name: 'Airtime',
      transaction_count: @airtime.count,
      transaction_amount: @airtime.sum("debit")
    },{
      name: 'Transfers',
      transaction_count: @transfers.count,
      transaction_amount: @transfers.sum("debit")
    },{
      name: 'Withdrawals',
      transaction_count: @withdrawals.count,
      transaction_amount: @withdrawals.sum("debit")
    },{
      name: 'Commissions',
      transaction_count: @commissions.count,
      transaction_amount: @commissions.sum("debit")
    },{
      name: 'Others',
      transaction_count: @others.count,
      transaction_amount: @others.sum("debit")
    }]
    @response['data'] = @transactions

    render json: @response.to_json
  end

  def income
    @response = {}
    @transactions = Sheet.find(params[:id]).rows.where({debit: nil})
    @months = @transactions.group_by { |x| x.date.beginning_of_month }
    @weeks = @transactions.group_by { |x| x.date.beginning_of_week }
    @income_total = @transactions.inject(0) {|sum,e| sum += e.credit }

    @pattern = []
    @months.each do |period, rows|
      m = period.month; y = period.year
      income = {
        period: period.strftime("%b %Y"),
        total: (rows.inject(0) {|sum,e| sum += e.credit }),
        average: (rows.inject(0) {|sum,e| sum += e.credit }) / (Time::days_in_month(m,y).to_f / 7)
      }
      @pattern.push(income)
    end

    @transactions = @transactions.where(date: DateTime.strptime(params[:month], '%b %Y').beginning_of_month..DateTime.strptime(params[:month], '%b %Y').end_of_month) if params[:month]

    @response['stats'] = {
      total: @income_total,
      subtotal: @transactions.inject(0) {|sum,e| sum += e.credit },
      average_month:  @income_total / @months.length,
      pattern: @pattern
    }

    @transfers = @transactions.where({tag: 2})
    @deposits = @transactions.where({tag: 6})
    @refunds = @transactions.where({tag: 5})
    @others = @transactions.where({tag: 0})

    @response['types'] = [{
      name: 'Transfers',
      transaction_count: @transfers.count,
      transaction_amount: @transfers.sum("credit")
    },{
      name: 'Deposits',
      transaction_count: @deposits.count,
      transaction_amount: @deposits.sum("credit")
    },{
      name: 'Refunds',
      transaction_count: @refunds.count,
      transaction_amount: @refunds.sum("credit")
    },{
      name: 'Others',
      transaction_count: @others.count,
      transaction_amount: @others.sum("credit")
    }]
    @response['data'] = @transactions

    render json: @response.to_json
  end

  def search
    @query = params[:query]
    @transactions = Sheet.find(params[:id]).rows.where("remarks ilike ?", "%#{@query}%")
    render json: @transactions.to_json
  end

  def destroy
    @sheet = Sheet.find(params[:id])
    if @sheet.destroy
      render json: {success: "Deleted Sheet"}, status: 200
    else
      render json: {errors: @sheet.errors}, status: 422
    end
  end

  private
    def validate_file(file)
      @rows = ["Trans Date", "Reference", "Value Date", "Debit", "Credit", "Balance", "Remarks"]
      unless file.row(18) == @rows && file.last_column == 7 && file.last_row > 26     
        render json: { message: "This is not a valid GTB transaction sheet #{file.row(18)}" }, status: 422 and return
      end
    end

  	def save_file(file, email)
      validate_file(file)

      @account = file.row(10)[0].scan(/\d+/)[0]
      @dates = file.row(14)[0].scan(/.....\d*..\d{4}/)
  		sheet = Sheet.new(name: @file.row(5)[0], address: @file.row(8)[0], account: @account, from: @dates[0], to: @dates[1])

  		if sheet.save
  			last_data_row = file.last_row - 9;
	  		file.each_with_index do |row, index|
	  			next if index < 18 || index > last_data_row
	  			row = Row.new(date: row[0], ref: row[1], debit: row[3], credit: row[4], balance: row[5], remarks: row[6], sheet_id: sheet.id)

          #Tagging - Others(0), Airtime(1), Transfers(2), Withdrawals(3), Commission(4), Refunds(5), Deposits(6),
          remarks = row.remarks.downcase
          if remarks.include?('airtime')
            row.tag = 1
          elsif remarks.include?('transfer')
            row.tag = 2
          elsif remarks.include?('instant payment')
            row.tag = 2
          elsif remarks.include?('commission')
            row.tag = 4
          elsif remarks.include?('withdrawal')
            row.tag = 3
          elsif remarks.include?('refund')
            row.tag = 5
          elsif remarks.include?('deposit')
            row.tag = 6
          else
            row.tag = 0
          end

	  			row.save
	  		end
	  	end

      CruncherMailer.crunched_statement(sheet, email).deliver_now

      render json: sheet.to_json
  	end
end
