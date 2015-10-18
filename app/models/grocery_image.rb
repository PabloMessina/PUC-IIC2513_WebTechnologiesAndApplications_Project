class GroceryImage < ActiveRecord::Base
	mount_uploader :grocery_image, ImageUploader
  belongs_to :grocery
end
