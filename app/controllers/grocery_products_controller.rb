class GroceryProductsController < ApplicationController
	include GroceryHelper

	before_action :set_logged_user_by_cookie
	before_action :set_privilege_on_grocery
	before_action :set_grocery_by_id
	before_action :set_product_by_id, only:[:show, :edit, :update, :destroy]


  def index
    puts "----------------------------------"
    puts "----------------------------------"
    puts params.inspect
    puts "----------------------------------"
    puts "----------------------------------"
    return unless check_grocery_exists

    filtered_params = search_params
    categories = filtered_params[:categories]
    tags = filtered_params[:tags]
    search_string = filtered_params[:search]
    puts "%%%%%%%%%%%%%%%%%%%%"
    puts categories
    puts tags
    puts search_string
    puts "%%%%%%%%%%%%%%%%%%%%"

    @products = @grocery.products
    if search_string && !search_string.blank?
      @products = @products.where("products.name LIKE ?","%#{search_string}%")
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

  def new
  	unless (check_grocery_exists &&
  					check_user_logged_in &&
  					check_privilege_on_grocery(:administrator))
  		return
  	end

  	@product = Product.new
  end

  def create
  	unless (check_grocery_exists &&
  		 			check_user_logged_in &&
  		 			check_privilege_on_grocery(:administrator))
  		return
  	end

  	filtered_params = product_params

  	@product = Product.new (filtered_params)
		if @product.save
			if filtered_params[:image]
				ProductImage.create(product_image: filtered_params[:image], product_id: @product.id)
			end

      if filtered_params[:category_mode] == 'existing_category'
        if filtered_params[:existing_category]
          cat_id = filtered_params[:existing_category].to_i
          category = Category.find_by_id(cat_id)
          if(category)
            category.products << @product
          end
        end
      else
        if filtered_params[:new_category]
          cat_name = filtered_params[:new_category]
          category = Category.where('name = ?',cat_name).first
          if(category)
            category.products << @product
          elsif !cat_name.blank?
            category = Category.create(name: cat_name)
            category.products << @product
          end
        end
      end

      existing_tags = filtered_params[:existing_tags]
      if existing_tags && existing_tags.size > 0
        existing_tags.each do |x|
          id = x.to_i
          tag = Tag.find_by_id(id)
          if(tag)
            @product.tags << tag
          end
        end
      end

      new_tags = filtered_params[:new_tags]
      if new_tags
        new_tags = new_tags.split(",")
        new_tags.each do |name|
          tag = Tag.where('name = ?',name).first
          if(tag)
            @product.tags << tag
          else
            tag = Tag.create(name: name)
            @product.tags << tag
          end
        end
      end

			redirect_to grocery_product_path(@grocery, @product)
		else
			render 'new'
		end
  end

  def show
  	unless (check_grocery_exists && check_product_exists && check_product_belongs_to_grocery)
  		return
  	end
  end

  def edit
  	unless (check_grocery_exists &&
  					check_product_exists &&
  					check_product_belongs_to_grocery &&
  					check_user_logged_in &&
  					check_privilege_on_grocery(:administrator))
  		return
  	end

  end

  def update
    unless (check_grocery_exists &&
            check_product_exists &&
            check_product_belongs_to_grocery &&
            check_user_logged_in &&
            check_privilege_on_grocery(:administrator))
      return
    end

    filtered_params = product_params
    if @product.update(filtered_params)

      if filtered_params[:image]
        if(@product.product_image)
          @product.product_image.update(product_image: filtered_params[:image])
        else
          ProductImage.create(product_image: filtered_params[:image], product_id: @product.id)
        end
      end

      if filtered_params[:category_mode] == 'existing_category'
        if filtered_params[:existing_category]
          cat_id = filtered_params[:existing_category].to_i
          category = Category.find_by_id(cat_id)
          if(category)
            category.products << @product
          end
        end
      else
        if filtered_params[:new_category]
          cat_name = filtered_params[:new_category]
          category = Category.where('name = ?',cat_name).first
          if(category)
            category.products << @product
          elsif !cat_name.blank?
            category = Category.create(name: cat_name)
            category.products << @product
          end
        end
      end

      existing_tags = filtered_params[:existing_tags]
      if existing_tags && existing_tags.size > 0
        existing_tags.each do |x|
          id = x.to_i
          tag = Tag.find_by_id(id)
          if(tag)
            begin
              @product.tags << tag
            rescue ActiveRecord::RecordNotUnique => e
            end
          end
        end
      end

      new_tags = filtered_params[:new_tags]
      if new_tags
        new_tags = new_tags.split(",")
        new_tags.each do |name|
          tag = Tag.where('name = ?',name).first
          if(tag)
            begin
              @product.tags << tag
            rescue ActiveRecord::RecordNotUnique => e
            end
          else
            tag = Tag.create(name: name)
            @product.tags << tag
          end
        end
      end

      flash[:success] = 'Product updated succesfully!'
      redirect_to grocery_product_path(@grocery, @product)
    else
      render 'edit'
    end
  end

	def destroy
		if(!@product.nil?)
			@product.destroy
			flash[:success] = "Product destroyed successfully!"
		else
			flash[:error] = "Product was nil"
		end
		redirect_to grocery_path(@grocery)
	end


  private

  	def set_product_by_id
  		@product = Product.find_by_id(params[:id])
  	end

  	def check_product_belongs_to_grocery
    	unless @product.grocery_id == @grocery.id
    		permission_denied ("Product with id #{params[:id]} does not belong to grocery with id #{params[:grocery_id]}")
    		return false;
    	end
    	return true;
  	end

  	def check_product_exists
  		unless @product
    		permission_denied ("Product with id #{params[:id]} not found")
    		return false;
    	end
    	return true;
  	end

  	def product_params
      p = params.require(:product).permit(
        :image, :name, :stock, :unit, :price, :category_mode, :existing_category,
        :new_category, {:existing_tags => []}, :new_tags);
      p[:grocery_id] = params[:grocery_id]
      if(p[:unit])
      	p[:unit] = p[:unit].to_sym
      end
      return p
  	end

    def search_params
      params.permit(:search, {categories: []}, {tags: []}, :page)
    end
end
