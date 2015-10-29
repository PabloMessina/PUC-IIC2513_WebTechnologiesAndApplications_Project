class CreateInventories < ActiveRecord::Migration
  def change
    create_table :inventories do |t|
      t.decimal :stock
      t.references :product, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
