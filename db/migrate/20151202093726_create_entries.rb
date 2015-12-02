class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.datetime :date
      t.string :ref
      t.boolean :transaction_type
      t.float :amount
      t.float :balance
      t.string :remarks
      t.integer :tag

      t.timestamps null: false
    end
  end
end
