class HomeController < ApplicationController
	before_action :set_logged_user_by_cookie
  def index
  	@groceries = Grocery.all.paginate(page: 1, per_page: 10)
		@following_groceries = @logged_user.following_groceries if @logged_user
		@following_groceries ||= []
  end
end
