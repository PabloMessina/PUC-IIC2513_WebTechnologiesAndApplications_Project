class SessionsController < ApplicationController
  before_action :set_logged_user_by_cookie, only: [:destroy]

	def new
    @dont_show_header = true;
	end

	def create
    user = User.find_by(username: params[:session][:username])
    if user && user.authenticate(params[:session][:password])
      sign_in user
      redirect_back_or user
    else
      flash.now[:error] = 'Invalid username/password combination'
      render 'new'
    end
  end

	def destroy
    sign_out
    flash[:success] = "Signed out succesfully!"
    redirect_to root_url
	end

end
