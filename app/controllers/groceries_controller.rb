class GroceriesController < ApplicationController
  before_action :set_logged_user_by_cookie
  before_action :set_grocery_by_id, only: [:show, :edit, :update, :destroy]
  before_action :set_privilege_on_grocery, only: [:show, :edit, :update, :destroy]

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
    @whats_news = @grocery.whats_news.paginate(page: 1, per_page: 10)
    @grocery_categories = Category.find_by_sql("select distinct c.id,c.name from categories
     as c, products as p where p.grocery_id = #{@grocery.id} and c.id = p.category_id");
    @grocery_tags = Tag.find_by_sql("select distinct t.id, t.name from tags as t, products_tags as pt, products as p
      where t.id = pt.tag_id and pt.product_id = p.id and p.grocery_id = #{@grocery.id}")
    puts "-------------------------------------"
    puts "-------------------------------------"
    puts @grocery_categories
    puts @grocery_tags
    puts "-------------------------------------"
    puts "-------------------------------------"
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

end
