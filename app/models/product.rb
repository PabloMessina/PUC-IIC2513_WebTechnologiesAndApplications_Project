class Product < ActiveRecord::Base

  # ojo: debe estar en orden 0,1,2,...
  @@units_matrix = [["-",0],["kg",1],["g",2],["L",3],["mL",4],["m",5]]

  def self.get_units_matrix
    @@units_matrix
  end

  def unit_to_string
    if self.unit
       @@units_matrix[self.unit][0]
   end
  end

end
