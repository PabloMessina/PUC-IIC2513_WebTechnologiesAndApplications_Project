class Grocery < ActiveRecord::Base
	has_many :privileges
	has_many :users, through: :privileges

	has_many :followers
	has_many :users, through: :followers

	has_many :products
end
