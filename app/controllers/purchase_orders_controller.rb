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
