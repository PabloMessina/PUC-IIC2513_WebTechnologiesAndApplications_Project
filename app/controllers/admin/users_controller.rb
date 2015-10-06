class Admin::UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :set_namespace


  def index
    @users = User.all
  end

  def new
    @user = User.new
    @submit_message = "Create user";
  end

  def edit
    @submit_message = "Edit user";
  end

  def show
    if(@user.nil?)
      flash[:error] = "ERROR: user with id #{params[:id]} could not be found"
      redirect_to admin_users_path
    end
  end

  def create
    @user = User.new(user_params)
    if @user.save
        flash[:success] = "SUCCESS: user registered successfully!"
        redirect_to admin_users_path
    else
      flash[:error] = "ERROR: user could not be registered!"
      render 'new'
    end
  end

  def update
    if @user.update(user_params)
      flash[:success] = "User successfully updated!"
      redirect_to admin_users_path
    else
      render 'edit'
    end
  end

  def destroy
    if(!@user.nil?)
      @user.destroy
      flash[:success] = "User destroyed successfully!"
    else
      flash[:error] = "User was nil"
    end
    redirect_to admin_users_path
  end

  private

    def set_user
      begin
        @user = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        @user = nil
      end
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name,:username,:password,:email,:password_confirmation, :address);
    end

    def set_namespace
      userExists = @user && !@user.new_record?
      @namespace = userExists ? admin_user_path(@user) : admin_users_path
    end

end
