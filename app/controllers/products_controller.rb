class ProductsController < ApplicationController

  def index

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

  private

    def search_params
      params.permit(:search, {categories: []}, {tags: []}, :page, :page_count)
    end

end	