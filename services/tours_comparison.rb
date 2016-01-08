require_relative './check_tour'
require_relative '../helpers/app_helper'

class CompareTours
  include LP_APIHelpers
  def call (req, settings)
    @settings = settings
    process_inputs(req)
    tour_comparison = countries_tours(@country_arr, @tour_categories, @tour_price_min, @tour_price_max)
    tour_comparison.to_json
  end


  private

  def process_inputs(req)
    @country_arr = remove_nil(req, 'tour_countries')
    @tour_categories = remove_nil(req, 'tour_categories')
    @tour_price_min = extract_min_price(req['inputPriceRange'])
    @tour_price_max = extract_min_price(req['inputPriceRange'])
  end

  # Remove nil values and return empty array
  def remove_nil(req, value)
    !req[value].nil? ? req['tour_countries'] : []
  end


  def process_price(price_string)
    price_string.nil? ? price_string.split(";").map(&:to_i) : [0, 999999]
  end

  def extract_min_price(price_string)
    process_price(price_string)[0]
  end

  def extract_max_price(price_string)
    process_price(price_string)[1]
  end



  # This return an object with the information of tours using the input data
  def countries_tours(country_arr, tour_categories, tour_price_min, tour_price_max)
    series_final = []
    drilldown_final = []
    tour_data_results = []
    tours_listings = []
    results = Hash.new
    final_results = Hash.new

    search_results = country_arr.each_with_index.each do |country,*|

        country_search = CheckTours.new.call(country, @settings)
       # country_tour_list = JSON.parse(country_search)['tours']
       # country_search.nil? ? continue : country_tour_list = JSON.parse(country_search)['tours']

       if !country_search.nil?
        series_data = []
    
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
          tour_data_results.each {|d| tours_listings.push( {title:d['title'][0,76]+'..', country:country, url:d['img'], price:strip_price(d['price']),category:d['category'] } )}
          series_data.push( {y:tour_data_results.count, drilldown:drilldown_label}) 
          drilldown_final.push( {id: drilldown_label, name: drilldown_label, data: tour_drilldown_results} )
        end
        series_final.push({name: country, data: series_data})
      end
    end.reject(&:blank?)

    results['series'] = series_final
    results['drilldown'] = drilldown_final
    results['categories'] = tour_categories
    results['countries'] = country_arr
    results['tours'] = tours_listings
    final_results['data'] = results
    
    logger = Logger.new(STDOUT)
    logger.info(JSON.pretty_generate(final_results))
    final_results
  end
end
