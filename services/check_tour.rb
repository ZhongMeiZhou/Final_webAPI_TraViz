require_relative '../models/lonely_planet_tours'

class CheckTours
  def call(country)
    return nil unless country
    
      tours = get_tours(country)
      return tours.to_json
    rescue
      nil
  end

  private

  # Use the model lonely_planet_tours to scrape the country's tours
  def get_tours(country)
    Tours.new(country)
  end

end
