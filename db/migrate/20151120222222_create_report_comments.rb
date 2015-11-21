class CreateReportComments < ActiveRecord::Migration
  def change
    create_table :report_comments do |t|
      t.text :content
      t.references :user, index: true, foreign_key: true
      t.references :report, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
