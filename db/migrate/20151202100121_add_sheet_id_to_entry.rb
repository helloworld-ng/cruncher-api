class AddSheetIdToEntry < ActiveRecord::Migration
  def change
    add_column :entries, :sheet_id, :string
  end
end
