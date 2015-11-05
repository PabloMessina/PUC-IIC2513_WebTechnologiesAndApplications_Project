class Star < ActiveRecord::Base

  belongs_to :product
  belongs_to :user
  validates :value, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 5 }

  after_create :update_star_counts_on_create
  after_save :update_star_counts_on_save

  private

  	def update_star_counts_on_create

  		puts "----------------------------------"
  		puts "FROM update_star_counts_create()"

  		star_count = StarCount.where("product_id = ?", self.product_id).first

  		puts "self.product_id = #{self.product_id}"
  		puts "star_count = #{star_count}"

  		case self.value
  		when 1
  			star_count.update_attributes(one: star_count.one+1)
  		when 2
  			star_count.update_attributes(two: star_count.two+1)
  		when 3
  			star_count.update_attributes(three: star_count.three+1)
  		when 4
  			star_count.update_attributes(four: star_count.four+1)
  		else 
  			star_count.update_attributes(five: star_count.five+1)
  		end

  		@skip_update_star_counts_save = true;

  	end

  	def update_star_counts_on_save

  		if @skip_update_star_counts_save
  			@skip_update_star_counts_save = false
  			return
  		end
 			return if self.value == self.value_was

  		star_count = StarCount.where("product_id = ?", self.product_id).first

  		to_update = {}

  		case self.value_was
  		when 1
  			to_update[:one] = star_count.one - 1
  		when 2
  			to_update[:two] = star_count.two - 1
  		when 3
  			to_update[:three] = star_count.three - 1
  		when 4
  			to_update[:four] = star_count.four - 1
  		else 
  			to_update[:five] = star_count.five - 1
  		end

  		case self.value
  	  when 1
  			to_update[:one] = star_count.one + 1
  		when 2
  			to_update[:two] = star_count.two + 1
  		when 3
  			to_update[:three] = star_count.three + 1
  		when 4
  			to_update[:four] = star_count.four + 1
  		else 
  			to_update[:five] = star_count.five + 1
  		end

  		star_count.update_attributes(to_update)

  	end


end
