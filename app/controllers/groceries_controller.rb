class GroceriesController < ApplicationController
  before_action :set_namespace
  before_action :set_logged_user_by_cookie
  before_action :set_grocery_by_id, only: [:show, :edit, :update, :destroy]

  def new
    unless signed_in?
      permission_denied ("You are not allowed to create a grocery unless you are logged in with a user account")
    end

    @grocery = Grocery.new
    @submit_message = "Create grocery";
  end

  def create
    unless signed_in?
      permission_denied ("You are not allowed to create a grocery unless you are logged in with a user account")
    end

    filtered_params = grocery_params
    @grocery = Grocery.new(filtered_params.except(:image))

    if @grocery.save
      flash[:success] = "Grocery created successfully!"
      if(filtered_params[:image])

        @grocery.grocery_image = GroceryImage.create(
            grocery_image: filtered_params[:image], 
            grocery_id: @grocery.id)
      end

      Privilege.create(
        user_id: @logged_user.id,
        grocery_id: @grocery.id, 
        privilege: :administrator)
      
      redirect_to grocery_path(@grocery)
    else 
      render 'new'
    end
  end

  def show
    unless @grocery
      permission_denied("Error: grocery with id #{params[:id]} could not be found")
    end
  end

  private

    def set_namespace
      grocery_exists = @grocery && !@grocery.new_record?
      @namespace = grocery_exists ? grocery_path(@grocery) : groceries_path
    end

    def set_grocery_by_id
      begin
        @grocery = Grocery.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        @grocery = nil
      end
    end

    def grocery_params
      params.require(:grocery).permit(:name, :address,:image)
    end

end
