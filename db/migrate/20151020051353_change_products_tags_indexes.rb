class ChangeProductsTagsIndexes < ActiveRecord::Migration
  def change
	  remove_index :products_tags, [:product_id, :tag_id]
	  remove_index :products_tags, [:tag_id, :product_id]
	  add_index :products_tags, [:product_id, :tag_id], unique: true
	  add_index :products_tags, [:tag_id, :product_id], unique: true
  end
end
