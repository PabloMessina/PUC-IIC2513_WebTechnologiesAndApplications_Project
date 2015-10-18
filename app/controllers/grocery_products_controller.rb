class GroceryProductsController < ApplicationController
	before_action :set_logged_user_by_cookie
	before_action :set_grocery_by_id
	#before_action :set_product_by_id, only:[]

  def new
  	check_grocery_exists
  	check_user_logged_in
  	check_logged_user_with_privilege_on_grocery(:administrator)
  	@product = Product.new
  end


  private

  	def set_grocery_by_id
  		@grocery = Grocery.find_by_id(params[:grocery_id])
  	end

  	def set_product_by_id
  		@product = Product.find_by_id(params[:id])
  	end

  	def check_product_belongs_to_grocery
    	unless @product.grocery_id == @grocery.id
    		permission_denied ("Product with id #{params[:id]} does not belong to grocery with id #{:grocery_id}")
    	end
  	end

  	def check_grocery_exists
  		unless @grocery
    		permission_denied ("Grocery with id #{params[:grocery_id]} not found")
    	end
  	end

  	def check_product_exists
  		unless @product
    		permission_denied ("Product with id #{params[:id]} not found")
    	end
  	end

  	def check_logged_user_with_privilege_on_grocery(privilege)
  		priv = @logged_user.privileges.find {|x| x.grocery_id.to_s == params[:grocery_id]}
  		if(priv.nil? || priv.privilege.to_sym != privilege)
  			permission_denied ("You (user_id #{@logged_user.id}) need a privilege of #{privilege} on the grocery with id #{params[:grocery_id]} to perform this action")
  		end
  	end

end	