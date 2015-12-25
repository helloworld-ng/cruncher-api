class ChangeTypeofTransactionTypeToInt < ActiveRecord::Migration
  def change
    change_column :entries, :transaction_type, 'integer USING CAST(transaction_type AS integer)'
  end
end
