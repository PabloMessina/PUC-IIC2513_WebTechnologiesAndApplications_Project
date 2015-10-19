class AddIndexToProduct < ActiveRecord::Migration
  def change
		add_index :products, [:grocery_id, :name], unique: true
  end
end
