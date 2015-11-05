class AddVisibilityToProducts < ActiveRecord::Migration
  def change
  	add_column :products, :visible, :boolean, default: true
  end
end
