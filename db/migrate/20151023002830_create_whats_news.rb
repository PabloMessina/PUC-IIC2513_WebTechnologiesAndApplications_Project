class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :name
      t.text :text
      t.references :grocery, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
