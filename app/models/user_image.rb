class UserImage < ActiveRecord::Base
	mount_uploader :user_image, ImageUploader
	belongs_to :user 
	validates :user_image, presence: true, on: :update
end
