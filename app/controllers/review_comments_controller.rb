class ReviewCommentsController < ApplicationController

  before_action :set_logged_user_by_cookie
  before_action :set_review_by_id  
  before_action :check_user_logged_in
  before_action :check_review_exists

  def create        
    filtered_params = comment_params
    filtered_params[:user_id] = @logged_user.id
    @comment = @review.comments.new(filtered_params)
    @saved = @comment.save
  end  

  def index    
    if(params.has_key?(:last_id)) 
      @comments = @review.comments.where('id < ?',params[:last_id].to_i).order(id: :desc).limit(10)
    else
      @comments = @review.comments.order(id: :desc).limit(10)
    end
  end

  private

    def set_review_by_id
      @review = Review.find_by_id(params[:review_id])
    end

    def check_review_exists
      unless @review
        raise ActionController::RoutingError.new("Review with id #{params[:review_id]} does not exist")
      end
    end

    def comment_params
        params.permit(:content)
    end



end
