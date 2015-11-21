class Grocery < ActiveRecord::Base
	attr_accessor :image

	has_many :privileges 	
	has_many :privileged_users, through: :privileges, source: :user

	has_many :followers
	has_many :follower_users, through: :followers, source: :user

	has_many :products, :dependent => :delete_all
	has_many :reports

	has_many :purchase_orders

	has_one :grocery_image, :dependent => :destroy

	validates :name, presence: true, length: { minimum: 1, maximum: 40 }, uniqueness: true
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

	def get_categories
		Category.find_by_sql("select distinct c.id,c.name from categories
     as c, products as p where p.grocery_id = #{self.id} and c.id = p.category_id");
	end

	def  get_tags
		Tag.find_by_sql("select distinct t.id, t.name from tags as t, products_tags as pt, products as p
      where t.id = pt.tag_id and pt.product_id = p.id and p.grocery_id = #{self.id}")
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
			json_str << %Q["#{p.id}" : {"name": "#{p.name}", "stock": #{p.inventory.stock} }]
		end
		json_str << "}"
		return json_str.html_safe
	end

	def get_users_per_privilege
		users = User.joins(:privileges).where('privileges.grocery_id = ?',self.id).select('privilege, users.*')
		inv_privileges = Privilege.privileges.invert
		priv_users = {}
		users.each do |user|
			priv = inv_privileges[user.privilege]
			next if priv.nil?			
			priv_users[priv] ||= []
			priv_users[priv] << user
		end
		return priv_users
	end

end
