class AddIndexToFollowers < ActiveRecord::Migration
  def change
  	add_index :followers, ["grocery_id", "user_id"], :unique => true
  end
end


