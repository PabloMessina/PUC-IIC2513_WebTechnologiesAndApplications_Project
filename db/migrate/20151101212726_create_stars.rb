class CreateStars < ActiveRecord::Migration
  def change
    create_table :stars do |t|
      t.integer :value
      t.references :product, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
