class PurchaseOrder < ActiveRecord::Base
	attr_accessor :order_lines_data
	attr_accessor :filtered_order_lines_data

  belongs_to :user
  belongs_to :grocery
  has_many :order_lines
  validate :check_order_lines

  def self.total_price(purchase_order_id)

  	query = PurchaseOrder.find_by_sql(
  		"SELECT sum(ol.amount * ol.product_price) as total_price 
  		FROM order_lines as ol 
  		WHERE ol.purchase_order_id = #{purchase_order_id}")

  	(query.first.total_price.nil?) ? '0' : query.first.total_price.to_s
  end

  private

  	def check_order_lines

  		puts "------------------------------------"
  		puts "------------------------------------"
  		puts "------------------------------------"
  		puts order_lines_data
  		puts "------------------------------------"
  		puts "------------------------------------"
  		puts "------------------------------------"

  		begin
  			array = JSON.parse(order_lines_data)
  		rescue
  			errors.add(:order_lines_data, " submitted does not meet JSON format")
  			return
  		end  		  		  		

  		puts "------------------------------------"
  		puts "------------------------------------"
  		puts "------------------------------------"
  		puts array
  		puts array.inspect
  		puts "------------------------------------"
  		puts "------------------------------------"
  		puts "------------------------------------"

  		if(!array.kind_of?(Array)) 
  			errors.add(:order_lines_data, " must be an array")
  			return
  		end

  		ids_set = Set.new

  		@filtered_order_lines_data = []

  		array.each do |x|
  			product_id = x["product_id"]
  			amount = x["amount"]

  			puts "--------------"
  			puts "en el each:"
  			puts "\t x = #{x.inspect}"
  			puts "\t product_id = #{product_id}"
  			puts "\t amount = #{amount}"

  			unless product_id && product_id.is_a?(Integer) && ids_set.add?(product_id)
  				next
  			end

  			product = Product.find_by_id(product_id)

  			if product.nil?
  				errors.add(:order_lines_data, ": product with id = #{product_id} not found")
  				next
  			end

  			unless amount && amount.is_a?(Numeric)
  				errors.add(:order_lines_data, ": provide a valid amount for product #{product.name}")
  				next
  			end

  			unless 0 < amount && amount <= product.stock
  				errors.add(:order_lines_data,": #{product.name}'s amount must be > 0 and <= #{product.stock}")
  				next
  			end

  			@filtered_order_lines_data << {product_id: product_id, amount: amount, product_price: product.price}
  		end

  		if(@filtered_order_lines_data.count == 0)
  			errors.add(:order_lines_data,": no valid order lines provided")
  		end

  	end

end
	