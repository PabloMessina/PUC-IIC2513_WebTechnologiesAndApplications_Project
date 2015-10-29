class Grocery < ActiveRecord::Base
	attr_accessor :image

	has_many :privileges
	has_many :users, through: :privileges

	has_many :followers
	has_many :users, through: :followers

	has_many :products
	has_many :reports

	has_many :purchase_orders

	has_one :grocery_image, :dependent => :destroy

	validates :name, presence: true, length: { minimum: 1, maximum: 40 }, uniqueness: true
	validates :address, presence: true

	def has_image?
		return self.grocery_image && !self.grocery_image.grocery_image.blank?
	end

	def purchases_data
		Grocery.find_by_sql("
			SELECT 	po.id as order_id, 
					po.created_at as purchase_date, 
					count(p.*) as products_count, 
					sum(ol.amount *  p.price) as total_price, 
					u.username as user_name, 
					u.id as user_id
					
			FROM 	purchase_orders as po, 
					users as u,
					order_lines as ol, 
					products as p
					
			WHERE	
					po.grocery_id = #{self.id} AND 
					u.id = po.user_id AND
					po.id = ol.purchase_order_id AND
					p.id = ol.product_id

			GROUP BY po.id, u.id, u.username
			ORDER BY purchase_date DESC")
	end
end
