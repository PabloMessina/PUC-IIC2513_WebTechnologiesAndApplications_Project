class GroceryProductsController < ApplicationController
	before_action :set_logged_user_by_cookie
	before_action :set_privilege_on_grocery
	before_action :set_grocery_by_id
	before_action :set_product_by_id, only:[:show, :edit, :update, :delete]


  def index
    return unless check_grocery_exists
    @products = @grocery.products.paginate(page: params[:page], per_page: 10)
  end

  def new
  	unless (check_grocery_exists &&
  					check_user_logged_in &&
  					check_privilege_on_grocery(:administrator))  	
  		return
  	end  

  	@product = Product.new
  end

  def create
  	unless (check_grocery_exists &&
  		 			check_user_logged_in &&
  		 			check_privilege_on_grocery(:administrator))
  		return
  	end

  	filtered_params = product_params
  	@product = Product.new (filtered_params.except(:image))
		if @product.save
			if filtered_params[:image]
				ProductImage.create(product_image: filtered_params[:image], product_id: @product.id)
			end
			redirect_to grocery_product_path(@grocery, @product)
		else
			render 'new'
		end
  end

  def show
  	unless (check_grocery_exists && check_product_exists && check_product_belongs_to_grocery)
  		return
  	end
  end

  def edit
  	unless (check_grocery_exists &&
  					check_product_exists && 
  					check_product_belongs_to_grocery &&
  					check_user_logged_in &&
  					check_privilege_on_grocery(:administrator))
  		return
  	end
  end

  def update
    unless (check_grocery_exists &&
            check_product_exists && 
            check_product_belongs_to_grocery &&
            check_user_logged_in &&
            check_privilege_on_grocery(:administrator))
      return
    end
    
    filtered_params = product_params
    if @product.update(filtered_params.except(:image))
      if filtered_params[:image]
        if(@product.product_image)
          @product.product_image.update(product_image: filtered_params[:image])
        else
          ProductImage.create(product_image: filtered_params[:image], product_id: @product.id)
        end
      end
      flash[:success] = 'Product updated succesfully!'
      redirect_to grocery_product_path(@grocery, @product)
    else
      render 'edit'
    end

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
    		permission_denied ("Product with id #{params[:id]} does not belong to grocery with id #{params[:grocery_id]}")
    		return false;
    	end
    	return true;
  	end

  	def check_grocery_exists
  		unless @grocery
    		permission_denied ("Grocery with id #{params[:grocery_id]} not found")
    		return false;
    	end
    	return true;
  	end

  	def check_product_exists
  		unless @product
    		permission_denied ("Product with id #{params[:id]} not found")
    		return false;
    	end
    	return true;
  	end

  	def check_privilege_on_grocery(privilege)
  		unless @privilege == privilege
  			permission_denied ("You (user_id = #{@logged_user.id}) need a privilege of #{privilege} on this grocery (id = #{params[:grocery_id]}) to perform this action")
  			return false;
  		end
  		return true;
  	end

  	def product_params
      p = params.require(:product).permit(:image, :name, :stock, :unit, :price);
      p[:grocery_id] = params[:grocery_id]
      if(p[:unit])
      	p[:unit] = p[:unit].to_sym
      end
      return p
  	end

end	