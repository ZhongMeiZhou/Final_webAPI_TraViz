require_relative '../models/lonely_planet_tours'

class CheckTours
  def call(country, settings)
    return nil unless country
      @settings = settings
      tours = get_tours(country)
      return tours.to_json
    rescue
      nil
  end

  private

  # Use the model lonely_planet_tours to scrape the country's tours
  def get_tours(country)
    cached_tours = get_cached_tours(country)
    if  cached_tours != nil
        {"country" => country, "tours" => cached_tours}
    else
        print "vamos a buscar en la base"
        tours = Tours.new(country)
        encache_traviz(country, JSON.parse(tours.to_json)['tours'])
        tours
    end
  end


  def get_cached_tours(country)
    #@settings.traviz_cache.fetch(country, ttl=@settings.traviz_cache_ttl) { tours.to_json}
    @settings.traviz_cache.get(country, ttl=@settings.traviz_cache_ttl)
  rescue => e
    logger.info "GET_CACHED_TOURS failed: #{e}"
    nil
  end

  def encache_traviz(country, tours)
    @settings.traviz_cache.set(country, tours, ttl=@settings.traviz_cache_ttl)
  rescue => e
    logger.info "ENCACHE_TRAVIZ failed: #{e}"
  end
end
