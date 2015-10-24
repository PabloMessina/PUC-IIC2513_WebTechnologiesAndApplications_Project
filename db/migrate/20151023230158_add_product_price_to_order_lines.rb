class AddProductPriceToOrderLines < ActiveRecord::Migration
  def change
    add_column :order_lines, :product_price, :integer
  end
end
