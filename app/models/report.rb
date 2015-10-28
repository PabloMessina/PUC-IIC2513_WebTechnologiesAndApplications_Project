class Report < ActiveRecord::Base
  belongs_to :grocery
  belongs_to :product
end
