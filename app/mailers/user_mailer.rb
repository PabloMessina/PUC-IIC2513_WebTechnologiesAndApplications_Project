class UserMailer < ApplicationMailer
	def new_report_email(report, grocery, user)
		@report = report
		@user = user
		@grocery = grocery
		mail(subject: "Latest news from #{grocery.name}", to: user.email)	
	end
end
