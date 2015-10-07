class User < ActiveRecord::Base
	has_many :privileges
	has_many :groceries, through: :privileges

	has_many :followers
	has_many :groceries, through: :followers

	def User.new_remember_token
  		SecureRandom.urlsafe_base64
  	end

	def User.encrypt(token)
		Digest::SHA1.hexdigest(token.to_s)
	end

end
