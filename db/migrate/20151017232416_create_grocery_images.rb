class CreateGroceryImages < ActiveRecord::Migration
  def change
    create_table :grocery_images do |t|
      t.string :grocery_image
      t.references :grocery, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
