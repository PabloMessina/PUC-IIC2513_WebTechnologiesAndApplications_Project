class ReportsController < ApplicationController
  include GroceryHelper
  layout 'groceries'

	before_action :set_logged_user_by_cookie
	before_action do set_grocery_by_id(:grocery_id) end
  before_action :set_privilege_on_grocery
	before_action :set_report_by_id, only:[:show, :edit, :update, :destroy]

  before_action do check_grocery_exists(:grocery_id) end
  before_action :check_user_logged_in, only: [:new, :create, :update, :destroy ]
  before_action only: [:new, :create, :edit, :update, :destroy] do check_privilege_on_grocery(:administrator, :grocery_id) end
  before_action :check_report_exists, only: [:edit, :update, :show]
  before_action :check_report_belongs_to_grocery, only: [:edit, :update, :show]

  def index
    @reports = @grocery.reports

    if params[:page]
      @reports = @reports.paginate(page: params[:page], per_page: 5)
    else
      @reports = @reports.paginate(page: 1, per_page: 5)
    end
  end

  def new
  	@report = Report.new
  end

  def create

    @report = Report.new(report_params)
    if @report.save
      flash[:success] = "News created successfully!"
      NotifyNewReportToFollowersJob.perform_later(@grocery,@report)
      redirect_to grocery_report_path(@grocery,@report)
    else
      render 'new'
    end

  end

  def show
    @comments = @report.comments.order(id: :desc).limit(10)
  end

  def edit
  end

  def update

    if @report.update(report_params)
      flash[:success] = 'News updated succesfully!'
      redirect_to grocery_report_path(@grocery,@report)
    else
      render 'edit'
    end
  end

  def destroy
		if(!@report.nil?)
			@report.destroy
			flash[:success] = "News destroyed successfully!"
		else
			flash[:error] = "News was nil"
		end
		redirect_to grocery_report_path(@grocery,@report)
	end


  private

  def set_report_by_id
    @report = Report.find_by_id(params[:id])
  end

  def check_report_belongs_to_grocery
    unless @report.grocery_id == @grocery.id
      raise ActionController::RoutingError.new("News with id #{params[:id]} does not belong to grocery with id #{params[:grocery_id]}")
    end
  end

  def check_report_exists
    unless @report
      raise ActionController::RoutingError.new("News with id #{params[:id]} not found")
    end
  end

  def report_params
    p = params.require(:report).permit(:title, :text);
    p[:grocery_id] = params[:grocery_id]
    p[:product_id] = params.require(:report)[:product]
    return p
  end

end
