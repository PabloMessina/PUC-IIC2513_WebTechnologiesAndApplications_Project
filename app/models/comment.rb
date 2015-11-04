class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :report

  validates :text, presence: true
end
