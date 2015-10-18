class AddDefaultValueToPrivilege < ActiveRecord::Migration
  def change
  	change_column :privileges, :privilege,  :integer, :default => 0
  end
end
