class User < ActiveRecord::Base	

	#virtual attributes for edit form
	attr_accessor :password, :password_confirmation
	attr_accessor :edit_password 
	attr_accessor :current_password
	attr_accessor :wrong_current_password
	attr_accessor :skip_password_validation
	attr_accessor :image

	has_many :privileges
	has_many :groceries, through: :privileges
	has_many :followers
	has_many :groceries, through: :followers
	has_one :user_image, :dependent => :destroy

	before_create :create_remember_token


	validates :username, presence: true, 
				length: { maximum: 25 },
				uniqueness: { case_sensitive: true }
	validates :first_name, presence: true, length: { maximum: 50 }
	validates :last_name, presence: true, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
	validates :email, presence:   true,
            format:     { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }

	has_secure_password
	validates :password, length: { minimum: 6, maximum: 30}, unless: :skip_password_validation
	validates :password_confirmation, presence: true, unless: :skip_password_validation
	validate :current_password_correct, unless: :skip_password_validation

	def User.new_remember_token
		SecureRandom.urlsafe_base64
	end

	def User.encrypt(token)
		Digest::SHA1.hexdigest(token.to_s)
	end

	def has_image?
		return self.user_image && !self.user_image.user_image.blank?
	end

	private

	  def create_remember_token
	  	self.remember_token = User.encrypt(User.new_remember_token)
	  end
	  
		def current_password_correct
			errors.add(:current_password, "provided is not correct") unless !wrong_current_password
		end
end
