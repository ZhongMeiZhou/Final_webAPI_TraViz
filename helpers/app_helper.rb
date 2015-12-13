require_relative '../models/lonely_planet_tours'

# define any helper functions
module LP_APIHelpers
	VERSION = '1.0.1'
  CATEGORIES = ['Small Group Tours', 'Adventure', 'Sightseeing', 'Health & Wellness', 'History & Culture', 'Water Sports', 'Short Break', 'Cycling', 'Nature & Wildlife', 'Holidays, Festivals & Seasonal']  #can scrape from lonely planet in case this updates

    def strip_price(value)
      value.gsub('$','').to_i
    end

    def price_in_range(price, min, max)
      price >= min && price <= max
    end

end
