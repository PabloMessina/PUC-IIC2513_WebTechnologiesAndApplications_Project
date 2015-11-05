class AddUserProductUniquenessToStars < ActiveRecord::Migration
  def change
  	add_index :stars, [:product_id, :user_id], unique: true
  end
end
