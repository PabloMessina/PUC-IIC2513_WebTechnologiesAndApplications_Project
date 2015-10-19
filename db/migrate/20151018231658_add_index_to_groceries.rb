class AddIndexToGroceries < ActiveRecord::Migration
  def change
  	add_index :groceries, :name, unique: true
  end
end
