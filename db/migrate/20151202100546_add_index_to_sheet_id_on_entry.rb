class AddIndexToSheetIdOnEntry < ActiveRecord::Migration
  def change
    add_index :entries, :sheet_id
  end
end
