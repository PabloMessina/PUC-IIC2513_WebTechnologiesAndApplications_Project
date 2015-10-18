class ProductImage < ActiveRecord::Base
	mount_uploader :product_image, ImageUploader
	belongs_to :product 
	validates :product_image, presence: true, on: :update
end
