class UsersController < ApplicationController
  before_action :set_namespace
  before_action :set_logged_user_by_cookie
  before_action :set_user_by_id, except:[:new, :create]
  before_action :check_user_exists, except:[:new, :create]
  before_action :check_user_logged_in, only:[:edit,:update,:destroy, :news_feed]
  before_action :check_user_matches_logged_user, only: [:edit,:update,:destroy, :news_feed]

  def show
    redirect_to user_news_feed_path(@user)
  end

	def new
		@user = User.new
  	@submit_message = "Create my account";
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
	end

  def update

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

  def news_feed
    @per_page = 10
    if(params.has_key?(:last_id))
      @reports = @user.get_next_reports_feed_chunk(params[:last_id].to_i,@per_page)
    else
      @reports = @user.get_next_reports_feed_chunk(nil,@per_page)
    end
  end

  def posted_news
    @per_page = 10
    if(params.has_key?(:last_id))
      @reports = @user.get_next_posted_news_chunk(params[:last_id].to_i,@per_page)
    else
      @reports = @user.get_next_posted_news_chunk(nil,@per_page)
    end
  end

  def following_groceries
    @groceries = @user.following_groceries
  end

  def associated_groceries
  end

	private

    def check_user_exists
      unless @user
        ActionController::RoutingError.new("User with id #{params[:id]} not found")
      end
    end

    def check_user_matches_logged_user
      unless user_id_matches_logged_user?
        ActionController::RoutingError.new("You are not allowed to edit this user's profile")
      end
    end

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
