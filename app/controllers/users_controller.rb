class UsersController < ApplicationController
	before_action :set_namespace


	def new
		@user = User.new
    	@submit_message = "Create my account";
	end

	def create
		@user = User.new(user_params)
		if @user.save
			sign_in @user
  			flash[:success] = "User registered successfully!"
  			redirect_to root_path
		else
			render 'new'
		end
	end

	private
		def user_params
			params.require(:user).permit(:first_name, :last_name,:username,:password,:email,:password_confirmation);
		end
	 	def set_namespace
	      @namespace = users_path
	    end
end