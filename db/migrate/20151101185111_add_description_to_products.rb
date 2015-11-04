class AddDescriptionToProducts < ActiveRecord::Migration
  def change
    add_column :products, :description, :text
    remove_column :products, :unit, :integer
  end
end
