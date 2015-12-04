require 'will_paginate/array'
require 'pagination_data.rb'

class PurchaseOrdersController < ApplicationController
	include GroceryHelper
	layout 'groceries'

	before_action :set_logged_user_by_cookie
	before_action do set_grocery_by_id(:grocery_id) end
	before_action :set_privilege_on_grocery
	before_action :set_purchase_order_by_id, only: [:show, :edit, :update, :destroy]

	before_action do check_grocery_exists(:grocery_id) end
	before_action :check_user_logged_in
	before_action do check_privilege_on_grocery(:administrator, :grocery_id) end
	before_action :check_purchase_order_exists, only: [:show, :edit, :update, :destroy]

	before_action :set_grocery_categories
  before_action :set_grocery_tags

	def index		  

		from_date = nil
		to_date = nil
		period = nil

  	if(params.has_key?(:period))
  		period = params[:period]
  	end

  	puts "period = #{period}"

  	if period == 'last_year'
  		from_date = (Date.today - 365).to_s
  		puts "period = last_year"
  	elsif period == 'last_month'
  		from_date = (Date.today - 30).to_s
  		puts "period = last_month"
  	elsif period == 'last_week'
  		from_date = (Date.today - 7).to_s
  		puts "period = last_week"
  	elsif period == 'custom_period'  		
  		puts "period = custom_period"

  		if(params.has_key?(:from_date))
		  	begin
		  		from_date = Date.strptime(params[:from_date], '%Y-%m-%d').to_s
		  	rescue ArgumentError
		  		from_date = nil
		  	end
	  	end

	  	if(params.has_key?(:to_date))
		  	begin
		  		to_date = Date.strptime(params[:to_date], '%Y-%m-%d').to_s
		  	rescue ArgumentError
		  		to_date = nil
		  	end
	  	end

	  end

	  puts "............."
	  puts "from_date = #{from_date}"
	  puts "to_date = #{to_date}"
	  puts "............."

	  @purchases_data = @grocery.purchases_data(from_date,to_date)

		respond_to do |format|
			format.html
			format.json { 
			  render json: @purchases_data
			} 
   	end

	end

	def show
		respond_to do |format|
			format.js
		end
	end

	def new
	  @purchase_order = PurchaseOrder.new
	  @order_lines_data = []
	  @selected_ids = []
	end

	def create

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
	  		product.inventory.update_attributes(stock: product.inventory.stock - x[:amount])
	  	end

	  	redirect_to grocery_purchase_order_path(@grocery,@purchase_order)
	  else
	  	begin
  			aux_array = JSON.parse(order_lines_data)
  			aux_array = [] unless aux_array.is_a? (Array)
  		rescue
  			aux_array = []
  		end

  		puts "------------------------------------"

  		puts aux_array.inspect

  		@order_lines_data = []
  		@selected_ids = []
  		aux_array.each do |x|

  			puts "----"
  			puts x.inspect

  			prid = x["product_id"]
  			amount = x["amount"]
  			product = Product.find_by_id(prid)
  			if(product.nil?)
  				next
  			end
  			@selected_ids << prid
  			@order_lines_data << {product_name: product.name, product_id: prid, amount: amount, stock: product.inventory.stock }
  		end

  		puts "-------------"
  		puts @order_lines_data


	  	render 'new'
	  end
	end

	def set_purchase_order_by_id
		@purchase_order = PurchaseOrder.find_by_id(params[:id])
	end

  def check_purchase_order_exists
    unless @purchase_order
    	raise ActionController::RoutingError.new("Purchase Order with id #{params[:id]} not found")
    end
  end

  def purchase_order_params
  	params.require(:purchase_order).permit(:order_lines_data)
  end

end
