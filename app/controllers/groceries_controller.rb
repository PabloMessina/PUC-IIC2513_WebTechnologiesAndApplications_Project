class GroceriesController < ApplicationController
  include GroceryHelper

  before_action :set_logged_user_by_cookie
  before_action only: [:show, :edit, :update, :destroy, :search_products] do set_grocery_by_id(:id) end
  before_action :set_privilege_on_grocery, only: [:show, :edit, :update, :destroy]

  before_action :check_user_logged_in, only: [:new, :create, :edit, :update, :destroy]
  before_action only: [:search_products, :edit, :update, :destroy] do check_grocery_exists(:id) end
  before_action only: [:edit, :update, :destroy] do check_privilege_on_grocery(:administrator, :id) end

  before_action :set_grocery_categories, except:[:follow, :unfollow]
  before_action :set_grocery_tags, except:[:follow, :unfollow]

  def index

    filtered_params = global_search_params
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

  def new
    @grocery = Grocery.new
    @submit_message = "Create grocery";
  end

  def create

    filtered_params = grocery_params
    @grocery = Grocery.new(filtered_params.except(:image))

    if @grocery.save
      flash[:success] = "Grocery created successfully!"
      if(filtered_params[:image])

        @grocery.grocery_image = GroceryImage.create(
            grocery_image: filtered_params[:image],
            grocery_id: @grocery.id)
      end

      Privilege.create(
        user_id: @logged_user.id,
        grocery_id: @grocery.id,
        privilege: :administrator)

      redirect_to grocery_path(@grocery)
    else
      render 'new'
    end
  end

  def show
    @products = @grocery.products.paginate(page: 1, per_page: 10)
    @users_per_privilege = @grocery.get_users_per_privilege
  end

  def edit
  end

  def update

    filtered_params = grocery_params

    if @grocery.update(filtered_params.except(:image))
      flash[:success] = "Grocery updated successfully!"

      if(filtered_params[:image])
        if(@grocery.grocery_image)
          @grocery.grocery_image.update(grocery_image: filtered_params[:image])
        else
          @grocery.grocery_image = GroceryImage.create(
            grocery_image: filtered_params[:image],
            grocery_id: @grocery.id)
        end
      end

      redirect_to grocery_path(@grocery)
    else
      render 'edit'
    end
  end

  def follow
    head :ok

    begin
      if params[:to] == 'true'
        Follower.create(
          user_id: @logged_user.id,
          grocery_id: params[:grocery_id])
      else
        # ??? Follower.destroy_all({ user_id: @logged_user.id, grocery_id: params[:grocery_id] })
        @logged_user.following_groceries.destroy(params[:grocery_id])
      end
    rescue ActiveRecord::RecordNotFound
    end
  end

  def unfollow
    begin
      @logged_user.following_groceries.delete(params[:grocery_id])      
      respond_to do |format|
        format.json { render json: nil, status: :ok } 
      end
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        format.json { render json: nil, status: :unprocessable_entity } 
      end
    end
  end

  helper_method :current_user_following_grocery
  def current_user_following_grocery
    @logged_user.following_groceries.exists?(@grocery.id)
  end

  def search_products

    filtered_params = grocery_search_params
    categories = filtered_params[:categories]
    tags = filtered_params[:tags]
    search_string = filtered_params[:search]

    @products = @grocery.products.where("products.visible = true")

    if search_string && !search_string.blank?
      @products = @products.where("products.name ILIKE ?","%#{search_string}%")
    end
    if categories && categories.count > 0
      @products = @products.where('products.category_id IN (?)',categories.map{|x|x.to_i} )
    end
    if tags && tags.count > 0
      @products = @products.where("(SELECT COUNT(*) FROM products_tags as pt WHERE
       pt.product_id = products.id AND pt.tag_id in (?)) = ?",tags.map{|x|x.to_i},tags.count)
    end
    if params[:page]
      @products = @products.paginate(page: params[:page], per_page: 10)
    else
      @products = @products.paginate(page: 1, per_page: 10)
    end

  end

  private

    def grocery_params
      params.require(:grocery).permit(:name, :address,:image)
    end

    def grocery_search_params
      params.permit(:search, {categories: []}, {tags: []}, :page, :page_count)
    end

    def global_search_params
      params.permit(:search, {categories: []}, {tags: []}, :page)
    end

end
