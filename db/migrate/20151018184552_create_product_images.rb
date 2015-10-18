class CreateProductImages < ActiveRecord::Migration
  def change
    create_table :product_images do |t|
      t.string :product_image
      t.product :references, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
