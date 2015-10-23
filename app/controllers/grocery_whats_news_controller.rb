class GroceryWhatsNewsController < ApplicationController
  include GroceryHelper

	before_action :set_logged_user_by_cookie
	before_action :set_privilege_on_grocery
	before_action :set_grocery_by_id
	before_action :set_whats_new_by_id, only:[:show, :edit, :update, :destroy]

  def index
    return unless check_grocery_exists
    @whats_news = @grocery.whats_news
  end

  def new
  	unless (check_grocery_exists &&
  					check_user_logged_in &&
  					check_privilege_on_grocery(:administrator))
  		return
  	end

  	@whats_new = WhatsNew.new
  end

  def create
  	unless (check_grocery_exists &&
  		 			check_user_logged_in &&
  		 			check_privilege_on_grocery(:administrator))
  		return
  	end

    @whats_new = WhatsNew.new(whats_new_params)
    if @whats_new.save
      flash[:success] = "WhatsNew created successfully!"
      redirect_to grocery_path(@grocery)
    else
      render 'new'
    end
  end

  def show
  	unless (check_grocery_exists
      && check_whats_new_exists
      && check_whats_new_belongs_to_grocery)
  		return
  	end
  end

  def edit
  	unless (check_grocery_exists &&
  					check_whats_new_exists &&
  					check_whats_new_belongs_to_grocery &&
  					check_user_logged_in &&
  					check_privilege_on_grocery(:administrator))
  		return
  	end
  end

  def update
    unless (check_grocery_exists &&
            check_whats_new_exists &&
            check_whats_new_belongs_to_grocery &&
            check_user_logged_in &&
            check_privilege_on_grocery(:administrator))
      return
    end

    if @whats_new.update(whats_new_params)
      flash[:success] = 'WhatsNew updated succesfully!'
      redirect_to grocery_path(@grocery)
    else
      render 'edit'
    end
  end

  def destroy
		if(!@whats_new.nil?)
			@whats_new.destroy
			flash[:success] = "WhatsNew destroyed successfully!"
		else
			flash[:error] = "WhatsNew was nil"
		end
		redirect_to grocery_path(@grocery)
	end


  private

  def set_whats_new_by_id
    @whats_new = WhatsNew.find_by_id(params[:id])
  end

  def check_whats_new_belongs_to_grocery
    unless @whats_new.grocery_id == @grocery.id
      permission_denied ("WhatsNew with id #{params[:id]} does not belong to grocery with id #{params[:grocery_id]}")
      return false;
    end
    return true;
  end

  def check_whats_new_exists
    unless @whats_new
      permission_denied ("WhatsNew with id #{params[:id]} not found")
      return false;
    end
    return true;
  end

  def whats_new_params
    #p = params.require(:whats_new).permit(:image, :title, :text, :product);
    p = params.require(:whats_new).permit(:title, :text, :product);
    p[:grocery_id] = params[:grocery_id]
    return p
  end

end
