class CreateUserImages < ActiveRecord::Migration
  def change
    create_table :user_images do |t|
      t.integer  :user_id
      t.string :user_image
      t.timestamps null: false
    end
  end
end
