class Privilege < ActiveRecord::Base
  belongs_to :user
  belongs_to :grocery
  enum privilege: {administrator: 0}
end
