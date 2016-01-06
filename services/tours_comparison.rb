require_relative './check_tour'
require_relative '../helpers/app_helper'

class CompareTours
  include LP_APIHelpers
  def call (req, settings)
    @settings = settings
    country_arr = !req['tour_countries'].nil? ? req['tour_countries'] : []
    tour_categories = !req['tour_categories'].nil? ? req['tour_categories'] : []
    price = !req['inputPriceRange'].nil? ? req['inputPriceRange'].split(";").map(&:to_i) : [0, 999999]
    tour_price_min = price[0] #!req['tour_price_min'].nil? ? req['tour_price_min'].to_i : 0
    tour_price_max = price[1] #!req['tour_price_max'].nil? ? req['tour_price_max'].to_i : 999999
    tour_comparison = countries_tours(country_arr, tour_categories, tour_price_min, tour_price_max)
    tour_comparison.to_json
  end

  private

  def countries_tours(country_arr, tour_categories, tour_price_min, tour_price_max)
    series_final = []
    drilldown_final = []
    tours_listings = []
    tour_data_results = []
    results = Hash.new
    final_results = Hash.new

    search_results = country_arr.each_with_index.each do |country,*|

        country_search = CheckTours.new.call(country, @settings)
       # country_tour_list = JSON.parse(country_search)['tours']
       # country_search.nil? ? continue : country_tour_list = JSON.parse(country_search)['tours']

       if !country_search.nil?
        series_data = []
        drilldown_data = []
    
        country_tour_list = JSON.parse(country_search)['tours']
        #id = get_country_id(country, country_tour_list) # why id? should just take appropriate action if country exists or not // This method provide the ID if exists in DB. If not, it will save it.
        tour_data = JSON.parse(Tour.find_by_country(country).tours)  # in first instance, I used ID here to look for the data.

        tour_categories.map do |category|
          drilldown_label = category+'-'+country
          tour_data_results = tour_data.select do |h|
              #only allow categories selected and withing price range to be included
             h['category'] == category && price_in_range(strip_price(h['price']), tour_price_min, tour_price_max)
          end
          tour_drilldown_results = tour_data_results.map {|v| {y: strip_price(v['price']), name: v['title'][0,25]+'...'}}

          series_data.push( {y:tour_data_results.count, drilldown:drilldown_label}) 
          drilldown_final.push( {id: drilldown_label, name: drilldown_label, data: tour_drilldown_results} )
        end
        tour_data_results.each {|d| tours_listings.push( {title:d['title'], country:country, url:d['img'] } )}
        series_final.push({name: country, data: series_data})
      end
    end.reject(&:blank?)

    results['series'] = series_final
    results['drilldown'] = drilldown_final
    results['categories'] = tour_categories
    results['tours'] = tours_listings
    final_results['data'] = results
    
    logger = Logger.new(STDOUT)
    logger.info(JSON.pretty_generate(final_results))
    final_results
  end
end
