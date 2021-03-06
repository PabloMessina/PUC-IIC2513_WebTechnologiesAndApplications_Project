class GroceryProductsController < ApplicationController
	include GroceryHelper
  layout 'groceries'

	before_action :set_logged_user_by_cookie
	before_action do set_grocery_by_id(:grocery_id) end
  before_action :set_privilege_on_grocery
	before_action :set_product_by_id, only:[:show, :edit, :update, :destroy, :rate_product]

  before_action do check_grocery_exists(:grocery_id) end
  before_action :check_user_logged_in, only: [:new, :create, :edit, :update, :destroy, :rate_product]
  before_action only: [:new, :create, :edit, :update, :destroy] do check_privilege_on_grocery(:administrator, :grocery_id) end
  before_action :check_product_exists, only: [:show, :edit, :update, :destroy, :rate_product]
  before_action :check_product_belongs_to_grocery, only: [:show, :edit, :update, :destroy, :rate_product]
  before_action :check_product_is_visible, only: [:show, :rate_product]

  before_action :set_grocery_categories
  before_action :set_grocery_tags

  def index

    filtered_params = search_params
    categories = filtered_params[:categories]
    tags = filtered_params[:tags]
    search_string = filtered_params[:search]


    @products = @grocery.products.where("products.visible = true")

    if search_string && !search_string.blank?
      @products = @products.where("products.name ILIKE ?","%#{search_string}%")
    end
    if categories && categories.count > 0
      @products = @products.where('products.category_id IN (?)',categories.map{|x|x.to_i} )
    end
    if tags && tags.count > 0
      @products = @products.where("(SELECT COUNT(*) FROM products_tags as pt WHERE
       pt.product_id = products.id AND pt.tag_id in (?)) = ?",tags.map{|x|x.to_i},tags.count)
    end
    if params[:page]
      @products = @products.paginate(page: params[:page], per_page: 10)
    else
      @products = @products.paginate(page: 1, per_page: 10)
    end

  end

  def new
  	@product = Product.new
    @product.setup_attributes_new
  end

  def create
  	filtered_params = product_params
  	@product = @grocery.products.new(filtered_params)
		if @product.save
      @product.update_category
      @product.update_tags
      flash[:success] = 'Product created successfully!'
			redirect_to grocery_product_path(@grocery, @product)
		else
      @product.setup_attributes_from_form
			render 'new'
		end
  end

  def show
	  # if @product.is_food
	  begin
		  query = @product.name.split.last
		  response = HTTParty.get("https://api.edamam.com/search?q=#{query}&to=1&app_id=c8dd31c8&app_key=c8171c7200ca6f626ceb1e8cacea6010")
		  j = ActiveSupport::JSON.decode(response.body)
		  recipe = j["hits"][0]["recipe"]
		  @recipe_title = recipe["label"]
		  @recipe_url = recipe["url"]
		  @recipe_image = recipe["image"]
	rescue
	end
  end

  def edit
    @product.setup_attributes_edit
  end

  def update
    filtered_params = product_params
    if @product.update_attributes(filtered_params)
      @product.update_category
      @product.update_tags
      flash[:success] = 'Product updated successfully!'
      redirect_to grocery_product_path(@grocery, @product)
    else
      @product.setup_attributes_from_form
      render 'edit'
    end
  end

  def destroy
    @product.destroy
    flash[:success] = 'Product deleted successfully!'
    redirect_to grocery_path(@grocery)
  end

  def rate_product
    begin
      @logged_user.stars.create(value: params[:value].to_i, product_id: @product.id)
    rescue ActiveRecord::RecordNotUnique => e
      render plain: e.message, status: :not_acceptable
      return
    end
    head :ok, content_type: "text/html"
  end

  private

  	def set_product_by_id
  		@product = Product.find_by_id(params[:id])
  	end

  	def check_product_belongs_to_grocery
      unless @product.grocery_id == @grocery.id
        raise ActionController::RoutingError.new("Product with id #{params[:id]} does not belong to grocery with id #{params[:grocery_id]}")
      end
  	end

  	def check_product_exists
      unless @product
        raise ActionController::RoutingError.new("Product with id #{params[:id]} not found")
      end
  	end

    def check_product_is_visible
      unless @privilege == :administrator || @product.visible == true
        raise ActionController::RoutingError.new("This product has been set as invisible by the grocery's administrators")
      end
    end

  	def product_params
      p = params.require(:product).permit(
        :image, :name, :stock, :price, :category_mode, :existing_category, :description, :visible,
        :new_category, {:existing_tags => []}, :new_tags, inventory_attributes: [:stock], product_image_attributes: [:product_image])

      if(p.has_key?(:product_image_attributes) && p[:product_image_attributes][:product_image].blank?)
        p.except!(:product_image_attributes)
      end

      return p
  	end

    def search_params
      params.permit(:search, {categories: []}, {tags: []}, :page)
    end
end
