class CreateFollowers < ActiveRecord::Migration
  def change
    create_table :followers, id:false do |t|
      t.belongs_to :user, index: true
      t.belongs_to :grocery, index: true

      t.timestamps null: false
    end
  end
end
