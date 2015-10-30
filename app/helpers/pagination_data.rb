class PaginationData
	attr_accessor :total_pages, :current_page
	def initialize (total_pages, current_page)
		@total_pages = total_pages
		@current_page = current_page
	end
end