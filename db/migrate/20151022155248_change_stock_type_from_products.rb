class ChangeStockTypeFromProducts < ActiveRecord::Migration
  def change
  	change_column :products, :stock, :decimal
  end
end
