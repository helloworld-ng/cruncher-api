class CreateRows < ActiveRecord::Migration
  def change
    create_table :rows do |t|
      t.datetime :date
      t.integer :ref, :limit => 8
      t.integer :debit
      t.integer :credit
      t.integer :balance
      t.string :remarks
      t.integer :tag
      t.string :sheet_id

      t.timestamps null: false
    end
  end
end
