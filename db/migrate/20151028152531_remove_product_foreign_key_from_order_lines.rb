class RemoveProductForeignKeyFromOrderLines < ActiveRecord::Migration
  def change
  	remove_foreign_key :order_lines, :products
  end
end
