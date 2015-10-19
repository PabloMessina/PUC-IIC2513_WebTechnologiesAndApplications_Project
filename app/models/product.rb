class Product < ActiveRecord::Base
  attr_accessor :image
  belongs_to :grocery
  has_one :product_image
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
