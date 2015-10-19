class Grocery < ActiveRecord::Base
	attr_accessor :image

	has_many :privileges
	has_many :users, through: :privileges

	has_many :followers
	has_many :users, through: :followers

	has_many :products

	has_one :grocery_image, :dependent => :destroy

	validates :name, presence: true, length: { minimum: 1, maximum: 25 }, uniqueness: true
	validates :address, presence: true

	def has_image?
		return self.grocery_image && !self.grocery_image.grocery_image.blank?
	end	

end
