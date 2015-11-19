class GroceriesController < ApplicationController
  before_action :set_logged_user_by_cookie
  before_action :set_grocery_by_id, only: [:show, :edit, :update, :destroy]
  before_action :set_privilege_on_grocery, only: [:show, :edit, :update, :destroy]

  before_action :check_grocery_exists, only: [:search_products]


  def index

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

  def new
    return unless check_user_logged_in

    @grocery = Grocery.new
    @submit_message = "Create grocery";
  end

  def create
    return unless check_user_logged_in

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
    return unless check_grocery_exists
    @products = @grocery.products.paginate(page: 1, per_page: 10)
    @reports = @grocery.reports.paginate(page: 1, per_page: 5)
    @grocery_categories = @grocery.get_categories
    @grocery_tags = @grocery.get_tags
    @privileged_users = @grocery.get_users_per_privilege
  end

  def edit
    unless (check_grocery_exists &&
            check_user_logged_in &&
            check_privilege_on_grocery(:administrator))
      return
    end
  end

  def update
    unless (check_grocery_exists &&
            check_user_logged_in &&
            check_privilege_on_grocery(:administrator))
      return
    end

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

  helper_method :current_user_following_grocery
  def current_user_following_grocery
    @logged_user.following_groceries.exists?(@grocery.id)
  end

  def search_products

  end
  private

    def set_grocery_by_id
      @grocery = Grocery.find_by_id(params[:id])
    end

    def set_privilege_on_grocery
      if(@logged_user)
        @privilege = @logged_user.privileges.find {|x| x.grocery_id.to_s == params[:id]}
        if(@privilege)
          @privilege = @privilege.privilege.to_sym
        end
      else
        @privilege = nil
      end
    end

    def check_grocery_exists
      unless @grocery
        permission_denied ("Grocery with id #{params[:id]} not found")
        return false;
      end
      return true;
    end

    def check_privilege_on_grocery(privilege)
      unless @privilege == privilege
        permission_denied ("You (user_id = #{@logged_user.id}) need a privilege of #{privilege} on this grocery (id = #{params[:id]}) to perform this action")
        return false;
      end
      return true;
    end

    def grocery_params
      params.require(:grocery).permit(:name, :address,:image)
    end

    def search_params
      params.permit(:search, {categories: []}, {tags: []}, :page, :page_count)
    end

end
