class PurchaseOrder < ActiveRecord::Base
  belongs_to :user
  belongs_to :grocery
  has_many :order_lines
end
	