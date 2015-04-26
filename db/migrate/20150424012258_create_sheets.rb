class CreateSheets < ActiveRecord::Migration
  def change
    create_table :sheets, id: false do |t|
      t.string :token, null: false
      t.string :name
      t.string :address
      t.string :account
      t.datetime :from
      t.datetime :to

      t.timestamps null: false
    end

    add_index :sheets, :token, unique: true
  end
end
