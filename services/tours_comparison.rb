require_relative './check_tour'
require_relative '../helpers/app_helper'

class CompareTours
  include LP_APIHelpers
  def call (req, settings)
    @settings = settings
    process_inputs(req)
    tour_comparison = countries_tours
    tour_comparison.to_json
  end

  private

  # This method process all the variables and set class variables 
  def process_inputs(req)
    @country_arr = remove_nil(req, 'tour_countries')
    @tour_categories = remove_nil(req, 'tour_categories')
    @tour_price_min = extract_min_price(req['inputPriceRange'])
    @tour_price_max = extract_max_price(req['inputPriceRange'])
  end

  # Remove nil values and return empty array
  def remove_nil(req, value)
    !req[value].nil? ? req[value] : []
  end

  # Process price atring and return an array of size 2 
  def process_price(price_string)
    price_string.nil? ? price_string.split(";").map(&:to_i) : [0, 999999]
  end

  # return min price value
  def extract_min_price(price_string)
    process_price(price_string)[0]
  end

  # return max price value
  def extract_max_price(price_string)
    process_price(price_string)[1]
  end

  def countries_tours
    series_final = []
    drilldown_final = []
    tour_data_results = []
    tours_listings = []
    filter_categories = []
    results = Hash.new
    final_results = Hash.new

    search_results = @country_arr.each_with_index.each do |country,*|

        country_search = CheckTours.new.call(country, @settings)
        
       if !country_search.nil?
        series_data = []
    
        country_tour_list = JSON.parse(country_search)['tours']
        #id = get_country_id(country, country_tour_list) # why id? should just take appropriate action if country exists or not // This method provide the ID if exists in DB. If not, it will save it.
        tour_data = JSON.parse(Tour.find_by_country(country).tours)  # in first instance, I used ID here to look for the data.


        drilldown_data = get_drilldown_data_by_category(country, tour_data)
        drilldown_final += drilldown_data[:drilldown_data]
        tours_listings += drilldown_data[:tours_listings]
        filter_categories += drilldown_data[:filter_categories]
        series_final.push({name: country, data: drilldown_data[:series_data]})
      end
    end.reject(&:blank?)

    results['series'] = series_final
    results['drilldown'] = drilldown_final
    results['categories'] = @tour_categories
    results['countries'] = @country_arr
    results['filtered_categories'] = filter_categories.uniq # use for listings of tour results
    results['all_categories'] = @tour_categories # need all categories for chart
    results['tours'] = tours_listings
    final_results['data'] = results
    
    logger = Logger.new(STDOUT)
    logger.info(JSON.pretty_generate(final_results))
    final_results
  end

  def get_drilldown_data_by_category(country, tour_data)
    series_data = []
    drilldown_final = []
    tours_listings = []
    filter_categories = []
    @tour_categories.map do |category|
      drilldown_label = category+'-'+country
      
      tour_data_results = filter_tours_by_category_and_price(tour_data, category)
      tour_drilldown_results = map_drilldown_results(tour_data_results)
      tour_data_results.map {|c| filter_categories.push({country: country, category: c['category']})}
      tour_data_results.each {|d| tours_listings.push( {title:d['title'][0,76]+'..', country:country, url:d['img'], price:strip_price(d['price']),category:d['category'] } )}
      
      series_data.push( {y:tour_data_results.count, drilldown:drilldown_label}) 
      
      drilldown_final.push( {id: drilldown_label, name: drilldown_label, data: tour_drilldown_results} )
    end
    return {series_data: series_data , drilldown_data: drilldown_final , tours_listings: tours_listings, filter_categories: filter_categories}
  end

  # Return object uses for drilldown
  def map_drilldown_results(tour_data_results)
    tour_data_results.map {|v| {y: strip_price(v['price']), name: v['title'][0,25]+'...'}}
  end

  def filter_tours_by_category_and_price(tour_data, category)
    result = tour_data.select do |h|
        #only allow categories selected and withing price range to be included
       h['category'] == category && price_in_range(strip_price(h['price']), @tour_price_min, @tour_price_max)
    end
  end
end
