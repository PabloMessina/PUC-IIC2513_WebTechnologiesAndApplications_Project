class Product < ActiveRecord::Base
  attr_accessor :image
  belongs_to :grocery
  has_one :product_image
  # ojo: debe estar en orden 0,1,2,...
  enum unit: {item: 0, kg:1, g:2, L:3, mL:4, m:5}

end
