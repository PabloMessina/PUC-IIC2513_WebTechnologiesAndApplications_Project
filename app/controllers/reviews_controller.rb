class ReviewsController < ApplicationController
  #sets
  before_action :set_logged_user_by_cookie
  before_action :set_product_by_id
  before_action :set_review_by_id, only: [:show, :edit, :update, :destroy]
  #checks
  before_action :check_product_exists
  before_action :check_user_logged_in, only: [:new, :create, :edit, :update, :destroy]
  before_action :check_user_is_author, only: [:edit, :update, :destroy]
  before_action :check_first_review, only: [:new]

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
    if(params.has_key?(:page))
      @reviews = @product.reviews.paginate(page: params[:page], per_page: 10)
    else
      @reviews = @product.reviews.paginate(page: 1, per_page: 10)
    end 
    @rating_titles = ["Excelent","Pretty Good","Acceptable","Kinda bad","Very bad"]
  end

  private

    def set_product_by_id
      @product = Product.find_by_id(params[:product_id])
    end

    def set_review_by_id
      @review = Review.find_by_id(params[:id])
    end

    def check_product_exists
      unless @product
        raise ActionController::RoutingError.new("Product with id #{params[:id]} not found")
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
