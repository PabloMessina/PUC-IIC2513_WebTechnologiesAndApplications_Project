class CreateReviewComments < ActiveRecord::Migration
  def change
    create_table :review_comments do |t|
      t.text :content
      t.references :review, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
