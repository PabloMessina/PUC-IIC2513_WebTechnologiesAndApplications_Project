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

	has_many :reviews
	has_many :stars
	has_many :review_comments
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


	def get_review_for(product_id)
		self.reviews.where("product_id = ?",product_id).first
	end

	def get_rating_for(product_id)
		self.stars.where("product_id = ?",product_id).first
	end

	def get_name
		self.first_name+' '+self.last_name
	end

	def get_next_reports_feed_chunk(id_ref, limit)		
		reports = Report.joins('INNER JOIN groceries ON groceries.id = reports.grocery_id').joins('INNER JOIN followers ON followers.grocery_id = groceries.id').where('followers.user_id = ?', self.id)
		reports = reports.where('reports.id < ?',id_ref) unless id_ref.nil?
		reports = reports.order('reports.id desc')
		reports = reports.limit(limit) unless limit.nil?
		return reports
	end


	private

	  def create_remember_token
	  	self.remember_token = User.encrypt(User.new_remember_token)
	  end

		def current_password_correct
			errors.add(:current_password, "provided is not correct") if wrong_current_password
		end
end
