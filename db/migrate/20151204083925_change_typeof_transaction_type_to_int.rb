class ChangeTypeofTransactionTypeToInt < ActiveRecord::Migration
  def change
    change_column :entries, :transaction_type, :integer
  end
end
