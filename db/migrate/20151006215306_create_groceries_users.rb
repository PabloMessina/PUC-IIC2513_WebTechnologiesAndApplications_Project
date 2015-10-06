class CreateGroceriesUsers < ActiveRecord::Migration
  def change
    create_table :groceries_users, id:false do |t|
		t.belongs_to :grocery, index: true
	    t.belongs_to :user, index: true
    end
  end
end
