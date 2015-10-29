class OrderLine < ActiveRecord::Base
  belongs_to :product
  belongs_to :purchase_order
end
