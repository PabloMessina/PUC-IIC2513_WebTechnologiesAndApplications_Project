module SessionsHelper

  def sign_in(user)
    remember_token = User.new_remember_token
    cookies.permanent[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.encrypt(remember_token))
    @logged_user = user
  end

  def signed_in?
  	@logged_user
  end

  def user_id_matches_logged_user?
    return @logged_user && @logged_user.id.to_s == params[:id]
  end

  def logged_user=(user) 
    @logged_user = user
  end

  def set_logged_user_by_cookie
    remember_token = User.encrypt(cookies[:remember_token])
    @logged_user ||= User.find_by(remember_token: remember_token)
  end   

  def sign_out
    logged_user.update_attribute(:remember_token, User.encrypt(User.new_remember_token))
    cookies.delete(:remember_token)
    self.logged_user = nil
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

end