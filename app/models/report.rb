class Report < ActiveRecord::Base
  belongs_to :grocery
  belongs_to :product
  has_many :comments, foreign_key: "report_id", class_name: "ReportComment", :dependent => :delete_all
end
