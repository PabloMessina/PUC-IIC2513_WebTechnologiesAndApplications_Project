class NotifyNewReportToFollowersJob < ActiveJob::Base
  queue_as :default

  def perform(grocery,report)
  	grocery.follower_users.each do |user|
  		UserMailer.new_report_email(report, grocery, user).deliver_now
  	end
  end

end
