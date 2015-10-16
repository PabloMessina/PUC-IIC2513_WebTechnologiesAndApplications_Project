class UsersController < ApplicationController
	before_action :set_user, only: [:show, :edit, :update, :destroy]
	before_action :set_namespace


	def new
		@user = User.new
  	@submit_message = "Create my account";
  	@dontShowHeader = true;
	end

 	def show
		if(@user.nil?)
      flash[:error] = "ERROR: user with id #{params[:id]} could not be found"
      redirect_to root_path
    end
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

	def edit
		if(@user.nil?)
      flash[:error] = "ERROR: user with id #{params[:id]} could not be found"
      redirect_to users_path
    end
	end

  def update

  	if(@user.nil?)
      flash[:error] = "ERROR: user with id #{params[:id]} could not be found"
      redirect_to users_path
  	else
  		filtered_params = edit_user_params
  		@user.wrong_current_password = false;
  		if(filtered_params[:edit_password] == 1)
  			could_authenticate = @user.try(:authenticate, filtered_params[:current_password])
  			if(!could_authenticate)
  				@user.wrong_current_password = true;
  			end
  			@user.skip_password_validation = false;	
  		else
  			filtered_params.except!(:password, :password_confirmation)
  			@user.skip_password_validation = true;
  		end

  		if(filtered_params[:image])
	  		if(@user.user_image)
	  			@user.user_image.update(user_image: filtered_params[:image])
	  		else
	  			@user.user_image = UserImage.new(:user_image => filtered_params[:image], :user_id => @user.id)
	  		end
	  	end

  		if @user.update(filtered_params)
	      flash[:success] = "User successfully updated!"
	      redirect_to user_path(@user)
	    else
	      render 'edit'
	    end
  	end    
  end

	private

		def user_params
      params.require(:user).permit(:first_name, :last_name,:username,:password,:email,:password_confirmation, :address);
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

    def set_user
      begin
        @user = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        @user = nil
      end
    end   
end