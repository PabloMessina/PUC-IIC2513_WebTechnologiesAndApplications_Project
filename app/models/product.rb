class Product < ActiveRecord::Base
  attr_accessor :image
  attr_accessor :category_mode
  attr_accessor :existing_category
  attr_accessor :new_category
  attr_accessor :existing_tags
  attr_accessor :new_tags

  belongs_to :grocery
  belongs_to :category
  has_one :product_image
  has_and_belongs_to_many :tags

  # ojo: debe estar en orden 0,1,2,...
  enum unit: {item: 0, kg:1, g:2, L:3, mL:4, m:5}

  validates :grocery, presence: true
  validates :name, presence: true, length: {minimum: 1, maximum: 30}
  validates :stock, presence: true
  validates :unit, presence: true
  validates :price, presence: true
  validates_uniqueness_of :name, allow_blank: false, scope: :grocery


  def has_image?
    return self.product_image && !self.product_image.product_image.blank?
  end 

end
