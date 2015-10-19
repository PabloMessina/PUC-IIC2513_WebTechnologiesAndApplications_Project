class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper

  def permission_denied (message)
  	render status: 401, text: message
  end 

  def check_user_logged_in
  	unless signed_in?
  		permission_denied("You must be logged in to perform this action")
  		return false;
  	end
  	return true;
  end

end