module GroceryHelper

  def set_grocery_by_id(grocery_key)
    @grocery = Grocery.find_by_id(params[grocery_key])
  end

  def set_privilege_on_grocery
    @privilege = nil
    return if(@grocery.nil?) 

    if(@logged_user)
      @privilege = @logged_user.privileges.where('privileges.grocery_id = ?',@grocery.id).first
      if(@privilege)
        @privilege = @privilege.privilege.to_sym
      end      
    end
  end

  def set_grocery_categories
    @grocery_categories = @grocery.get_categories
  end

  def set_grocery_tags      
    @grocery_tags = @grocery.get_tags
  end

  def check_grocery_exists(grocery_key)
    unless @grocery
      raise ActionController::RoutingError.new("Grocery with id #{params[grocery_key]} not found")
    end
  end

  def check_privilege_on_grocery(privilege, grocery_key)
    unless @privilege == privilege
      raise ActionController::RoutingError.new("You (user_id = #{@logged_user.id}) need a privilege of #{privilege} on this grocery (id = #{params[grocery_key]}) to perform this action")
    end
  end

end
