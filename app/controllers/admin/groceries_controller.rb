class Admin::GroceriesController < ApplicationController
  before_action :set_grocery, only: [:show, :edit, :update, :destroy]
  before_action :set_namespace


  def index
    @groceries = Grocery.all
  end

  def new
    @grocery = Grocery.new
    @submit_message = "Create grocery";
  end

  def edit
    @submit_message = "Edit grocery";
  end

  def show
    if(@grocery.nil?)
      flash[:error] = "ERROR: grocery with id #{params[:id]} could not be found"
      redirect_to admin_groceries_path
    end    
    @grocery_categories = Category.find_by_sql("select distinct c.id,c.name from categories
     as c, products as p where p.grocery_id = #{@grocery.id} and c.id = p.category_id");
    @grocery_tags = @grocery.products.joins("product_tags").joins("tags").select("tags.id,tags.name")
    puts "-------------------------------------"
    puts "-------------------------------------"
    puts @grocery_categories
    puts @grocery_tags
    puts "-------------------------------------"
    puts "-------------------------------------"
  end

  def create
    @grocery = Grocery.new(grocery_params)
    if @grocery.save
        flash[:success] = "SUCCESS: Grocery successfully created!"
        redirect_to admin_groceries_path
    else
      flash[:error] = "ERROR: grocery could not be created!"
      render 'new'
    end
  end

  def update
    if @grocery.update(grocery_params)
      flash[:success] = "Grocery successfully updated!"
      redirect_to admin_groceries_path
    else
      render 'edit'
    end
  end

  def destroy
    if(!@grocery.nil?)
      @grocery.destroy
      flash[:success] = "Grocery destroyed successfully!"
    else
      flash[:error] = "User was nil"
    end
    redirect_to admin_groceries_path
  end

  private

    def set_grocery
      begin
        @grocery = Grocery.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        @grocery = nil
      end
    end

    def grocery_params
      params.require(:grocery).permit(:name, :address);
    end

    def set_namespace
      grocery_exists = @grocery && !@grocery.new_record?
      @namespace = grocery_exists ? admin_grocery_path(@grocery) : admin_groceries_path
    end

end
