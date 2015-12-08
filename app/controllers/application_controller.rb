class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper

  def permission_denied (message)
  	render status: 401, text: message
  end

  def title(text)
    content_for :title, text
  end

  helper_method :is_administrator?
  def is_administrator?
    @privilege == :administrator
  end

  def check_user_logged_in
  	unless signed_in?
      raise ActionController::RoutingError.new("You must be logged in to perform this action")
  	end
  end

end
