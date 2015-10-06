class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :username
      t.string :password
      t.string :password_confirmation
      t.string :email
      t.string :address
      t.string :remember_token
    
      t.timestamps null: false
    end
    
    add_index :users, :remember_token

  end
end
