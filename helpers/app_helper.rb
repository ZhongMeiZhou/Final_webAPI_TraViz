require_relative '../models/lonely_planet_tours'

# define any helper functions
module LP_APIHelpers
	VERSION = '1.0.1'

    def strip_price(value)
      value.gsub('$','').to_i
    end

    def price_in_range(price, min, max)
      price >= min && price <= max
    end
    
end
