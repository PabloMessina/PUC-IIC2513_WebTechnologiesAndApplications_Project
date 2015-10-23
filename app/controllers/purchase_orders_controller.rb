require 'will_paginate/array'

class PurchaseOrdersController < ApplicationController	
	before_action :set_logged_user_by_cookie
	before_action :set_privilege_on_grocery
	before_action :set_grocery_by_id

	def index			

unless (check_grocery_exists && 
        check_user_logged_in &&
        check_privilege_on_grocery(:administrator))
			)
	    return
	  end

	  if(params[:page])
	  	@purchases_data = @grocery.purchases_data.paginate(page: params[:page], per_page: 2)
	  else
	  	@purchases_data = @grocery.purchases_data.paginate(page: 1, per_page: 2)
	  end

	end

	def new
	end

	def create
	end

	def set_grocery_by_id
		@grocery = Grocery.find_by_id(params[:grocery_id])
	end

	def set_privilege_on_grocery
		if(@logged_user)
		  @privilege = @logged_user.privileges.find {|x| x.grocery_id.to_s == params[:grocery_id]}
		  if(@privilege) 
		  	@privilege = @privilege.privilege.to_sym
		  end
		else
			@privilege = nil
		end
	end


  def check_grocery_exists
    unless @grocery
      permission_denied ("Grocery with id #{params[:grocery_id]} not found")
      return false;
    end
    return true;
  end

  def check_privilege_on_grocery(privilege)
    unless @privilege == privilege
      permission_denied ("You (user_id = #{@logged_user.id}) need a privilege of #{privilege} on this grocery (id = #{params[:grocery_id]}) to perform this action")
      return false;
    end
    return true;
  end

end
