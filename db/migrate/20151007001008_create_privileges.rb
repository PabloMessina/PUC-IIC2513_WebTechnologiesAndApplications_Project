class CreatePrivileges < ActiveRecord::Migration
  def change
    create_table :privileges, id:false do |t|
      t.belongs_to :user, index: true
      t.belongs_to :grocery, index: true

      t.integer :privilege
      t.timestamps null: false
    end
  end
end
