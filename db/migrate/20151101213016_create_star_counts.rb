class CreateStarCounts < ActiveRecord::Migration
  def change
    create_table :star_counts do |t|
      t.integer :one
      t.integer :two
      t.integer :three
      t.integer :four
      t.integer :five
      t.references :product, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
