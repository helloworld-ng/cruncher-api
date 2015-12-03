require 'rubygems'
require 'ng-bank-parser'
require 'tempfile'
require 'date'
module Cruncher
  class SheetResource < Grape::API

    # general helper methods used by endpoints
    helpers do
      # json representation of sheet object
      def set_sheet sheet
        {
          token: sheet.token,
          name: sheet.name,
          address: sheet.address,
          bank: sheet.bank,
          account: sheet.account,
          from: sheet.from,
          to: sheet.to,
          created_at: sheet.created_at,
          updated_at: sheet.updated_at,
          email: sheet.email
        }
      end

      def set_transaction transaction
        {
          date: transaction[:date],
          ref: transaction[:ref],
          amount: transaction[:amount],
          balance: transaction[:balance],
          remarks: transaction[:remarks],
          tag: transaction[:tag],
          sheet_id: transaction[:sheet_id],
          transaction_type: if (transaction[:type] == 'debit') then 0 else 1 end
        }
      end

      def set_trend_data sheet
        income_amount_and_credits = sheet.get_income_amount_and_credits
        expense_amount_and_debits = sheet.get_expense_amount_and_debits
        {
          incomeAmount: income_amount_and_credits[1],
          expenseAmount: expense_amount_and_debits[1],
          credits: income_amount_and_credits[0],
          debits: expense_amount_and_debits[0],
          categories: sheet.get_categories_data,
          monthlySummary: sheet.get_monthly_summary
        }
      end


      # add a tag to each transaction based on text in remarks
      def add_tag_to_transaction transaction
        remarks = transaction[:remarks].downcase
        if remarks.include?('airtime')
          transaction[:tag] = 1
        elsif remarks.include?('transfer')
          transaction[:tag] = 2
        elsif remarks.include?('instant payment')
          transaction[:tag] = 2
        elsif remarks.include?('commission')
          transaction[:tag] = 4
        elsif remarks.include?('withdrawal')
          transaction[:tag] = 3
        elsif remarks.include?('refund')
          transaction[:tag] = 5
        elsif remarks.include?('deposit')
          transaction[:tag] = 6
        else
          transaction[:tag] = 0
        end
      end
    end


    resource :sheets do

      desc 'Verify if a sheet has been crunched'
      params do
        requires :token
      end
      # GET /meta
      get :meta do
        @sheet = Sheet.find_by_token(params[:token])
        if @sheet then set_sheet(@sheet) else
          error!({errors: "Couldn't find the sheet you requested for" }, 422) end
      end


      desc 'takes a bank sheet and returns due response - if it’s created or not'
      params do
        requires :email
        requires :bank_code
        requires :bank_sheet, type: Rack::Multipart::UploadedFile
      end
      # POST /crunch
      post :crunch do
        result = NgBankParser::Router.parse(params[:bank_code], params[:bank_sheet][:tempfile].path)
        if result[:status] == 1
          sheet = Sheet.new(name: result[:data][:account_name], address: '', bank: result[:data][:bank_name],account: result[:data][:account_number],
                            from: result[:data][:from_date], to: result[:data][:to_date], email: params[:email])
          if sheet.save
            transactions = result[:data][:transactions]
            transactions.each do |transaction|
              puts transaction.class
              transaction[:sheet_id] = sheet.token
              add_tag_to_transaction(transaction)
            end
            transactions = transactions.collect {|transaction| Entry.new(set_transaction(transaction)) }
            Entry.import transactions
          end
          CruncherMailer.crunched_statement(sheet, params[:email]).deliver_now
          { token: sheet.token }
        else
          error!({errors: result[:message] }, 422)
        end
      end


      route_param :token do

        desc 'returns trend data for a bank sheet'
        get :trends do
          @sheet = Sheet.find_by_token(params[:token])
          set_trend_data(@sheet)
        end

      end

    end

  end
end
