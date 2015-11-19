class UsersController < ApplicationController
	before_action :set_namespace
  before_action :set_logged_user_by_cookie
  before_action :set_user_by_id, only:[:show]

  def show
    unless @user
      permission_denied ("ERROR: user with id #{params[:id]} could not be found") 
    end
  end

	def new
		@user = User.new
  	@submit_message = "Create my account";
  	@dont_show_header = true;
	end

	def create
    filtered_params = user_params
		@user = User.new(filtered_params)
		if @user.save
			sign_in @user
			flash[:success] = "User registered successfully!"
			redirect_to root_path
		else
			render 'new'
		end
	end

	def edit
    unless user_id_matches_logged_user?
      permission_denied ("You are not allowed to edit this user's profile") 
    end   
	end

  def update

    unless user_id_matches_logged_user?
      permission_denied ("You are not allowed to edit this user's profile") 
    end
      
		filtered_params = edit_user_params

		@logged_user.wrong_current_password = false;
		if(filtered_params[:edit_password] == 1)
			could_authenticate = @logged_user.try(:authenticate, filtered_params[:current_password])
			if(!could_authenticate)
				@logged_user.wrong_current_password = true;
			end
			@logged_user.skip_password_validation = false;	
		else
			filtered_params.except!(:password, :password_confirmation)
			@logged_user.skip_password_validation = true;
		end

    #create a new image for the user
		if(filtered_params[:image])
  		if(@logged_user.user_image)
  			@logged_user.user_image.update(user_image: filtered_params[:image])
  		else
  			@logged_user.user_image = UserImage.new(:user_image => filtered_params[:image], :user_id => @logged_user.id)
  		end
  	end

		if @logged_user.update(filtered_params)
      flash[:success] = "User successfully updated!"
      redirect_to user_path(@logged_user)
    else
      render 'edit'
    end 

  end

	private

		def user_params
      params.require(:user).permit(:first_name, :last_name,:username,:password,:password_confirmation,:email, :address);
    end

    def edit_user_params    	
      params.require(:user).
      	permit(:image,:first_name,:last_name,:username,:edit_password,
      				 :current_password,:password,:password_confirmation, 
      				 :email, :address);
    end

    def set_namespace
      userExists = @user && !@user.new_record?
      @namespace = userExists ? user_path(@user) : users_path
    end

    def set_user_by_id
      begin
        @user = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        @user = nil
      end
    end
end