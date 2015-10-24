require 'will_paginate/array'
require 'pagination_data.rb'

class PurchaseOrdersController < ApplicationController	
	before_action :set_logged_user_by_cookie
	before_action :set_privilege_on_grocery
	before_action :set_grocery_by_id
	before_action :set_purchase_order_by_id, only: [:show, :edit, :update, :destroy]

	def index			
		unless (check_grocery_exists && 
		        check_user_logged_in &&
		        check_privilege_on_grocery(:administrator))
	    return
	  end

	  page = 1
	  per_page = 20
	  @page_count = nil

	  if(params.has_key?(:page))
  		page = params[:page].to_i
  		page = 1 unless page > 0
  	end

  	if(params.has_key?(:page_count))
  		@page_count = params[:page_count].to_i
  		@page_count = nil unless @page_count > 0
  	end

  	if(@page_count.nil?)
	  	@purchases_data = @grocery.purchases_data_with_count(page: page, per_page: per_page)
	  	if(@purchases_data.count > 0)
	  		@total_entries = @purchases_data[0][:total_count];
	  		@page_count = (@total_entries / per_page.to_f).ceil
	  	else
	  		@page_count = 1
	  		@total_entries = 0
	  	end	  
	  else
	  	@purchases_data = @grocery.purchases_data_without_count(page: page, per_page: per_page)
	  	@total_entries = @page_count * per_page
	  end	

	  @pagination_data = PaginationData.new(@page_count, page)
	end

	def show
		unless (check_grocery_exists && 
						check_purchase_order_exists &&
		        check_user_logged_in &&
		        check_privilege_on_grocery(:administrator))
	    return
	  end
	end

	def new
		unless (check_grocery_exists && 
	        check_user_logged_in &&
	        check_privilege_on_grocery(:administrator))
	    return
	  end
	  @purchase_order = PurchaseOrder.new
	  @order_lines_data = []
	  @selected_ids = []
	end

	def create
		unless (check_grocery_exists && 
			      check_user_logged_in &&
			      check_privilege_on_grocery(:administrator))
  		return
	  end

	  filtered_params = purchase_order_params

	  order_lines_data = ""
	  if(filtered_params.has_key?(:order_lines_data))
	  	order_lines_data = filtered_params[:order_lines_data]
	  end

	  @purchase_order = PurchaseOrder.new(grocery_id: @grocery.id, order_lines_data: order_lines_data)

	  if(@purchase_order.save)	  	

	  	@purchase_order.filtered_order_lines_data.each do |x|
	  		@purchase_order.order_lines.
	  		create(	product_id: 		x[:product_id], 
	  						amount: 				x[:amount], 
	  						product_price: 	x[:product_price])
	  		product = Product.find_by_id(x[:product_id])
	  		product.update_attribute(:stock, product.stock - x[:amount])
	  	end

	  	redirect_to grocery_purchase_orders_path(@grocery)
	  else	  	
	  	begin
  			aux_array = JSON.parse(order_lines_data)
  			aux_array = [] unless aux_array.is_a? (Array)
  		rescue
  			aux_array = []
  		end 

  		@order_lines_data = []
  		@selected_ids = []
  		aux_array.each do |x|
  			prid = x["product_id"]
  			amount = x["amount"]
  			product = Product.find_by_id(prid)
  			if(product.nil?)
  				next
  			end
  			@selected_ids << prid
  			@order_lines_data << {product_name: product.name, product_id: prid, amount: amount, stock: product.stock }
  		end

	  	render 'new'
	  end
	end

	def set_grocery_by_id
		@grocery = Grocery.find_by_id(params[:grocery_id])
	end

	def set_purchase_order_by_id
		@purchase_order = PurchaseOrder.find_by_id(params[:id])
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


  def check_grocery_exists
    unless @grocery
      permission_denied ("Grocery with id #{params[:grocery_id]} not found")
      return false;
    end
    return true;
  end

  def check_purchase_order_exists
    unless @purchase_order
      permission_denied ("Purchase Order with id #{params[:id]} not found")
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

  def purchase_order_params 
  	params.require(:purchase_order).permit(:order_lines_data)
  end 

end
