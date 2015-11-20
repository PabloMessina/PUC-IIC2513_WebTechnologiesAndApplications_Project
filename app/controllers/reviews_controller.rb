class ReviewsController < ApplicationController
  include GroceryHelper
  layout 'groceries'

  #sets
  before_action :set_logged_user_by_cookie
  before_action :set_product_by_id
  before_action :set_review_by_id, only: [:show, :edit, :update, :destroy]
  before_action :set_rating_titles, only: [:show, :index]
  #checks
  before_action :check_product_exists
  before_action :check_user_logged_in, only: [:new, :create, :edit, :update, :destroy]
  before_action :check_review_exists, only: [:show, :edit, :update, :destroy]
  before_action :check_user_is_author, only: [:edit, :update, :destroy]
  before_action :check_first_review, only: [:new]

  before_action :set_grocery
  before_action :set_privilege_on_grocery
  before_action :set_grocery_categories
  before_action :set_grocery_tags

  def new
    @review = Review.new
  end

  def create
    filtered_params = review_params    
    filtered_params[:product_id] = @product.id
    @review = @logged_user.reviews.new(filtered_params)
    if @review.save
      flash[:success] = "Review submitted successfully!"
      redirect_to product_reviews_path(@product)
    else
      render 'new'
    end    
  end

  def index
    page = params.has_key?(:page) ? params[:page] : 1
    @reviews = @product.reviews.order(created_at: :desc).paginate(page: page, per_page: 10)
  end

  def show   
    @comments = @review.comments.order(id: :desc).paginate(page: 1, per_page: 10)
  end

  private

    def set_product_by_id
      @product = Product.find_by_id(params[:product_id])
    end

    def set_review_by_id
      @review = Review.find_by_id(params[:id])
    end

    def set_grocery
      @grocery = @product.grocery
    end

    def set_rating_titles
      @rating_titles = ["Excelent","Pretty Good","Acceptable","Kinda bad","Very bad"] 
    end

    def check_product_exists
      unless @product
        raise ActionController::RoutingError.new("Product with id #{params[:product_id]} not found")
      end
    end

    def check_review_exists
      unless @review
        raise ActionController::RoutingError.new("Review with id #{params[:id]} not found")
      end
    end

    def check_user_is_author
      unless !!@logged_user.reviews.find_by_id(@review)
        raise ActionController::RoutingError.new("You are not allowed to alter this review because you are not the author")
      end
    end

    def check_first_review
      unless !@logged_user.get_review_for(@product.id)
        raise ActionController::RoutingError.new("You already wrote a review for this product")
      end
    end

    def review_params
      params.require(:review).permit(:title,:content,:rating)
    end

end
