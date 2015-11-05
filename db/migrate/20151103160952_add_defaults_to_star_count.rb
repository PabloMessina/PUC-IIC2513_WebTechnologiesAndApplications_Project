class AddDefaultsToStarCount < ActiveRecord::Migration
  def change
  	change_column :star_counts, :one,  :integer, :default => 0
  	change_column :star_counts, :two,  :integer, :default => 0
  	change_column :star_counts, :three,  :integer, :default => 0
  	change_column :star_counts, :four,  :integer, :default => 0
  	change_column :star_counts, :five,  :integer, :default => 0
  end
end
