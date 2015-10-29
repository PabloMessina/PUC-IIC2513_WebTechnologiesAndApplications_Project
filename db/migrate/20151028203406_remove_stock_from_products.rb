class RemoveStockFromProducts < ActiveRecord::Migration
  def change
    remove_column :products, :stock, :decimal
  end
end
