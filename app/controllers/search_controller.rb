class SearchController < ApplicationController
	before_action :set_logged_user_by_cookie

  def products
    # TODO: se podrá hacer sin tanto copy-paste?

    filtered_params = search_params
    categories = filtered_params[:categories]
    tags = filtered_params[:tags]
    search_string = filtered_params[:search]

    @products = Product.all.where("products.visible = true")
    if search_string && !search_string.blank?
      @products = @products.where("products.name ILIKE ?","%#{search_string}%")
    end
    if categories && categories.count > 0
      @products = @products.where('products.category_id IN (?)',categories.map{|x|x.to_i} )
    end
    if tags && tags.count > 0
      @products = @products.joins("INNER JOIN products_tags as pt ON products.id = pt.product_id")
      .where("pt.tag_id IN (?)", tags.map{ |x| x.to_i })
      .group("products.id").having("SUM(DISTINCT pt.tag_id) = ?", tags.count).select("products.*")
    end

	if params[:page]
	  @products = @products.paginate(page: params[:page], per_page: 10)
	else
	  @products = @products.paginate(page: 1, per_page: 10)
	end
  end


  def groceries
    filtered_params = search_params
    categories = filtered_params[:categories]
    tags = filtered_params[:tags]
    search_string = filtered_params[:search]

    page = 1
    per_page = 3
    @page_count = nil

    if filtered_params.has_key?(:page)
      page = filtered_params[:page].to_i if filtered_params[:page].is_i?
      page = 1 if page < 1
    end

    if filtered_params.has_key?(:page_count)
      @page_count = filtered_params[:page_count].to_i if filtered_params[:page_count].is_i?
      @page_count = nil unless @page_count >= 0
    end

    @has_search_string = !search_string.blank?
    @has_categories = categories && categories.count > 0
    @has_tags = tags && tags.count > 0

    cond_count = 0
    cond_count+=1 if @has_search_string
    cond_count+=1 if @has_categories
    cond_count+=1 if @has_tags

    if cond_count > 0

      query = "WITH "
      first = true
      i = 1

      if @has_search_string
        query << "gids#{i} as (SELECT g.id
          FROM groceries as g
          WHERE g.name ILIKE '%#{search_string}%')"
        first = false
        i+=1
      end

      if @has_tags
        query << "," unless first
        query <<
        "gids#{i} as (
          SELECT p.grocery_id as id
          FROM products as p, products_tags as pt #{first ? "" : ", gids#{i-1}"}
          WHERE #{first ? "" : "gids#{i-1}.id = p.grocery_id AND "} p.id = pt.product_id and pt.tag_id IN (
            #{tags.join(',')})
          GROUP BY p.grocery_id
          HAVING COUNT(DISTINCT pt.tag_id) = #{tags.count})"
        first = false
        i+=1
      end

      if @has_categories
        query << "," unless first
        query <<
        "gids#{i} as (SELECT p.grocery_id as id
          FROM products as p #{first ? "" : ", gids#{i-1}"}
          WHERE #{first ? "" : "gids#{i-1}.id = p.grocery_id AND "} p.category_id IN (#{categories.join(',')})
          GROUP BY p.grocery_id
          HAVING COUNT(DISTINCT p.category_id) = #{categories.count})"
        first = false
        i+=1
      end

      with_tab = "gids#{i-1}";

      if @page_count.nil?
        query << "SELECT g.*, count(*) over() as total_count
        FROM groceries as g, #{with_tab}
        WHERE #{with_tab}.id = g.id
        LIMIT #{per_page}
        OFFSET #{(page-1) * per_page}"
        @groceries = Grocery.find_by_sql(query)
        if(@groceries.count > 0)
          total_entries = @groceries[0][:total_count]
          @page_count = (total_entries / per_page.to_f).ceil
        else
          @page_count = 1
        end
      else
        query << "SELECT g.*
        FROM groceries as g, #{with_tab}
        WHERE #{with_tab}.id = g.id
        LIMIT #{per_page}
        OFFSET #{(page-1) * per_page}"
        @groceries = Grocery.find_by_sql(query)
      end

    else
      @groceries = Grocery.all.paginate(page: page, per_page: per_page)
      @page_count = @groceries.total_pages
    end

    @pagination_data = PaginationData.new(@page_count, page)

  end


  private

    def search_params
      params.permit(:search, {categories: []}, {tags: []})
    end

end
