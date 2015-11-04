class ReportsController < ApplicationController
  include GroceryHelper

	before_action :set_logged_user_by_cookie
	before_action :set_privilege_on_grocery
	before_action :set_grocery_by_id
	before_action :set_report_by_id, only:[:show, :edit, :update, :destroy]

  def index
    return unless check_grocery_exists
    @reports = @grocery.reports

    if params[:page]
      @reports = @reports.paginate(page: params[:page], per_page: 5)
    else
      @reports = @reports.paginate(page: 1, per_page: 5)
    end
  end

  def new
  	unless (check_grocery_exists &&
  					check_user_logged_in &&
  					check_privilege_on_grocery(:administrator))
  		return
  	end

  	@report = Report.new
  end

  def create
  	unless (check_grocery_exists &&
  		 			check_user_logged_in &&
  		 			check_privilege_on_grocery(:administrator))
  		return
  	end

    @report = Report.new(report_params)
    if @report.save
      flash[:success] = "News created successfully!"
      redirect_to grocery_path(@grocery)
      return
    else
      render 'new'
    end
  end

  def show
  	unless (check_grocery_exists &&
      check_report_exists &&
      check_report_belongs_to_grocery)
  		return
  	end
  end

  def edit
  	unless (check_grocery_exists &&
  					check_report_exists &&
  					check_report_belongs_to_grocery &&
  					check_user_logged_in &&
  					check_privilege_on_grocery(:administrator))
  		return
  	end
  end

  def update
    unless (check_grocery_exists &&
            check_report_exists &&
            check_report_belongs_to_grocery &&
            check_user_logged_in &&
            check_privilege_on_grocery(:administrator))
      return
    end

    if @report.update(report_params)
      flash[:success] = 'News updated succesfully!'
      redirect_to grocery_path(@grocery)
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
		redirect_to grocery_path(@grocery)
	end


  private

  def set_report_by_id
    @report = Report.find_by_id(params[:id])
  end

  def check_report_belongs_to_grocery
    unless @report.grocery_id == @grocery.id
      permission_denied ("News with id #{params[:id]} does not belong to grocery with id #{params[:grocery_id]}")
      return false;
    end
    return true;
  end

  def check_report_exists
    unless @report
      permission_denied ("News with id #{params[:id]} not found")
      return false;
    end
    return true;
  end

  def report_params
    p = params.require(:report).permit(:title, :text);
    p[:grocery_id] = params[:grocery_id]
    p[:product_id] = params.require(:report)[:product]
    return p
  end

end
