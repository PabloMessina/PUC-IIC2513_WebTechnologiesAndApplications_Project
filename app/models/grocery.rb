class Grocery < ActiveRecord::Base
	attr_accessor :image

	has_many :privileges
	has_many :users, through: :privileges

	has_many :followers
	has_many :users, through: :followers

	has_many :products

	has_many :purchase_orders

	has_one :grocery_image, :dependent => :destroy

	validates :name, presence: true, length: { minimum: 1, maximum: 25 }, uniqueness: true
	validates :address, presence: true

	def has_image?
		return self.grocery_image && !self.grocery_image.grocery_image.blank?
	end	

	def purchases_data_with_count (args)
		Grocery.find_by_sql("
			SELECT 	po.id as order_id, 
							po.created_at as purchase_date, 
							count(ol.*) as products_count, 
							sum(ol.amount *  ol.product_price) as total_price, 
							count(*) over() as total_count
							
			FROM 	purchase_orders as po, 
						order_lines as ol
					
			WHERE	po.grocery_id = #{self.id} AND 
						po.id = ol.purchase_order_id

			GROUP BY po.id
			ORDER BY purchase_date DESC
			LIMIT #{args[:per_page]}
			OFFSET #{args[:per_page] * (args[:page]-1)}")
	end

	def purchases_data_without_count (args)
		 Grocery.find_by_sql("
			SELECT 	po.id as order_id, 
							po.created_at as purchase_date, 
							count(ol.*) as products_count, 
							sum(ol.amount *  ol.product_price) as total_price
					
			FROM 	purchase_orders as po, 
						order_lines as ol
					
			WHERE	po.grocery_id = #{self.id} AND 
						po.id = ol.purchase_order_id

			GROUP BY po.id
			ORDER BY purchase_date DESC
			LIMIT #{args[:per_page]}
			OFFSET #{args[:per_page] * (args[:page]-1)}")
	end

	def products_purchase_data_to_JSON
		json_str = "{"
		first = true
		self.products.each  do |p|
			if first
				first = false
			else
				json_str << ","
			end
			json_str << %Q["#{p.id}" : {"name": "#{p.name}", "stock": #{p.stock} }]
		end
		json_str << "}"
		return json_str.html_safe
	end

end
