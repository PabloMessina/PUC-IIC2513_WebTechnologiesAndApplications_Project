class StarCount < ActiveRecord::Base
  belongs_to :product

  def get_percentages
  	den = self.one + self.two + self.three + self.four + self.five
  	return [0,0,0,0,0] if den == 0
  	fac = 100 / den.to_f
  	return [self.one * fac, self.two * fac, self.three * fac, self.four * fac, self.five * fac]
  end

  def get_rating_average
  	den = self.one + self.two + self.three + self.four + self.five
  	return 0 if den == 0
  	return (self.one + self.two * 2 + self.three * 3 + self.four * 4 + self.five * 5) / den.to_f
  end

  def get_rating_percentage_average
  	den = self.one + self.two + self.three + self.four + self.five
  	return 0 if den == 0
  	return 20 * (self.one + self.two * 2 + self.three * 3 + self.four * 4 + self.five * 5) / den.to_f
  end

  def get_total_count
  	return self.one + self.two + self.three + self.four + self.five
  end

end
