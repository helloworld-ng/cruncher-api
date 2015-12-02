class AddEmailBankColumnsToSheet < ActiveRecord::Migration
  def change
    add_column :sheets, :bank, :string
    add_column :sheets, :email, :string
  end
end
