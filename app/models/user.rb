class User < ActiveRecord::Base

	#virtual attributes for edit form
	attr_accessor :edit_password
	attr_accessor :current_password
	attr_accessor :wrong_current_password
	attr_accessor :skip_password_validation
	attr_accessor :image

	has_many :privileges
	has_many :privileged_groceries, through: :privileges, source: :grocery
	has_many :followers
	has_many :following_groceries, through: :followers, source: :grocery
	has_many :purchase_orders
	has_one :user_image, :dependent => :destroy
	has_many :comments

	before_create :create_remember_token


	validates :username, presence: true,
				length: { minimum: 1, maximum: 25 },
				uniqueness: { case_sensitive: true }
	validates :first_name, presence: true, length: { maximum: 50 }
	validates :last_name, presence: true, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
	validates :email, presence:   true,
            format:     { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }

	has_secure_password
	validates :password, length: { minimum: 6, maximum: 30}, unless: :skip_password_validation
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

	def get_name
		self.first_name+' '+self.last_name
	end

	private

	  def create_remember_token
	  	self.remember_token = User.encrypt(User.new_remember_token)
	  end

		def current_password_correct
			errors.add(:current_password, "provided is not correct") if wrong_current_password
		end
end
