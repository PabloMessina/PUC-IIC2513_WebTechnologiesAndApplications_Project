class Review < ActiveRecord::Base
	attr_accessor :rating	

  belongs_to :product
  belongs_to :user
  has_many :comments, foreign_key: "review_id", class_name: "ReviewComment"

  validates :rating, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 5 }
  validates_length_of :content, :minimum => 1, :maximum => 1000, :allow_blank => false

  after_create :create_associated_rating

  def create_associated_rating
  	star = get_associated_rating
  	if(star.nil?)
  		Star.create(value: self.rating, product_id: self.product_id, user_id: self.user_id)
  	end
  end

  def get_associated_rating
  	Star.where("product_id = ? AND user_id = ?",self.product_id, self.user_id).first
  end

end
