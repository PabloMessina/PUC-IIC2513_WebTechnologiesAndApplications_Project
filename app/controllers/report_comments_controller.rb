class ReportCommentsController < ApplicationController

  before_action :set_logged_user_by_cookie
  before_action :set_report_by_id  
  before_action :check_user_logged_in
  before_action :check_report_exists

  def create        
    filtered_params = comment_params
    filtered_params[:user_id] = @logged_user.id
    @comment = @report.comments.new(filtered_params)
    @saved = @comment.save
  end  

  def index    
    if(params.has_key?(:last_id)) 
      @comments = @report.comments.where('id < ?',params[:last_id].to_i).order(id: :desc).limit(10)
    else
      @comments = @report.comments.order(id: :desc).limit(10)
    end
  end

  private

    def set_report_by_id
      @report = Report.find_by_id(params[:report_id])
    end

    def check_report_exists
      unless @report
        raise ActionController::RoutingError.new("Report with id #{params[:report_id]} does not exist")
      end
    end

    def comment_params
        params.permit(:content)
    end

end
