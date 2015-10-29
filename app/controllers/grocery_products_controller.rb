class GroceryProductsController < ApplicationController
	before_action :set_logged_user_by_cookie
	before_action :set_privilege_on_grocery
	before_action :set_grocery_by_id
	before_action :set_product_by_id, only:[:show, :edit, :update, :destroy]

  before_action :check_grocery_exists
  before_action :check_user_logged_in, only: [:new, :create, :update, :destroy]
  before_action only: [:new, :create, :update, :destroy] do check_privilege_on_grocery(:administrator) end
  before_action :check_product_exists, only: [:show, :edit, :update, :destroy]
  before_action :check_product_belongs_to_grocery, only: [:show, :edit, :update, :destroy]

  def index

    filtered_params = search_params
    categories = filtered_params[:categories]
    tags = filtered_params[:tags]
    search_string = filtered_params[:search]

    @products = @grocery.products    
    if search_string && !search_string.blank?
      @products = @products.where("products.name LIKE ?","%#{search_string}%")
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
  end

  def edit
    @product.setup_attributes_edit
  end

  def update    
    filtered_params = product_params
    if @product.update(filtered_params)     
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

  private

  	def set_grocery_by_id
  		@grocery = Grocery.find_by_id(params[:grocery_id])
  	end

  	def set_product_by_id
  		@product = Product.find_by_id(params[:id])
  	end

  	def set_privilege_on_grocery
  		if(@logged_user)
  		  @privilege = @logged_user.privileges.find {|x| x.grocery_id.to_s == params[:grocery_id]}
  		  if(@privilege) 
  		  	@privilege = @privilege.privilege.to_sym
  		  end
  		else
  			@privilege = nil
  		end
  	end

  	def check_product_belongs_to_grocery
      unless @product.grocery_id == @grocery.id
        raise ActionController::RoutingError.new("Product with id #{params[:id]} does not belong to grocery with id #{params[:grocery_id]}")
      end
  	end

  	def check_grocery_exists
  		unless @grocery
        raise ActionController::RoutingError.new("Grocery with id #{params[:grocery_id]} not found")
    	end
  	end

  	def check_product_exists
      unless @product
        raise ActionController::RoutingError.new("Product with id #{params[:id]} not found")
      end
  	end

  	def check_privilege_on_grocery(privilege)
      unless @privilege == privilege
        raise ActionController::RoutingError.new("You (user_id = #{@logged_user.id}) need a privilege of #{privilege} on this grocery (id = #{params[:grocery_id]}) to perform this action")
      end
  	end

  	def product_params
      p = params.require(:product).permit(
        :image, :name, :stock, :unit, :price, :category_mode, :existing_category, 
        :new_category, {:existing_tags => []}, :new_tags, inventory_attributes: [:stock], product_image_attributes: [:product_image]);
      if(p[:unit])
      	p[:unit] = p[:unit].to_sym
      end
      return p
  	end

    def search_params
      params.permit(:search, {categories: []}, {tags: []}, :page)
    end
end	