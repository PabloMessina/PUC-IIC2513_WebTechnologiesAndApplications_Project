class HomeController < ApplicationController
	before_action :set_logged_user_by_cookie
  def index
  end
end
