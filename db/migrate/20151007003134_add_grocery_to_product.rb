class AddGroceryToProduct < ActiveRecord::Migration
  def change
    add_reference :products, :grocery, index: true, foreign_key: true
  end
end
