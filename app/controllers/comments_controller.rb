class CommentsController < ApplicationController
  include GroceryHelper

  before_action :set_logged_user_by_cookie
  before_action :set_grocery_by_id
  before_action :set_comment_by_id, only:[:show, :edit, :update, :destroy]

  def index
    return unless check_grocery_exists
    @comments = @report.comments
  end

  def new
    @comment = Comment.new
  end

  def create
    @comment = Comment.new(comment_params)
    if @comment.save
      flash[:success] = "Comment posted successfully!"
      redirect_to grocery_path(@grocery)
      return
    else
      render 'new'
    end
  end




  private

  def set_comment_by_id
    @comment = Comment.find_by_id(params[:id])
  end

  def comment_params
    p = params.require(:comment).permit(:text);
    p[:report_id] = params[:report_id]
    return p
  end

end