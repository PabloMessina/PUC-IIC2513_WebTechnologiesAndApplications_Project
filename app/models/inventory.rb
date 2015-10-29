class Inventory < ActiveRecord::Base
  belongs_to :product
  validates :stock, presence: true, numericality: {allow_nil: false, greater_than_or_equal_to: 0}
end
