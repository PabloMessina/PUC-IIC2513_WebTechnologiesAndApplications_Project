class CreateOrderLines < ActiveRecord::Migration
  def change
    create_table :order_lines do |t|
      t.references :product, index: true, foreign_key: true
      t.references :purchase_order, index: true, foreign_key: true
      t.decimal :amount

      t.timestamps null: false
    end
  end
end
