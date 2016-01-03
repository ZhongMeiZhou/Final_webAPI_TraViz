require_relative './check_tour'
require_relative '../helpers/app_helper'

class CompareTours
  include LP_APIHelpers
  def call (req)
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

    search_results = country_arr.each_with_index.map do |country,*|
      

      #begin
        country_search = CheckTours.new.call(country)


       # country_tour_list = JSON.parse(country_search)['tours']
       # country_search.nil? ? continue : country_tour_list = JSON.parse(country_search)['tours']

       if !country_search.nil?
        results = Hash.new
        data = []
        country_tour_list = JSON.parse(country_search)['tours']
        id = get_country_id(country, country_tour_list) # why id? should just take appropriate action if country exists or not

        results['name'] = country
        tour_data = JSON.parse(Tour.find_by_country(country).tours)

        tour_categories.map do |category|
          num_per_category = 0
          num_per_category = tour_data.select do |h|
           #if tour_categories.include?(category) do #add criteria to only allow categories selected to be included
             h['category'] == category && price_in_range(strip_price(h['price']), tour_price_min, tour_price_max)
          # end
          end.count
          results['data'] = data.push([category, num_per_category])
        end
       
        #results['total_tours'] = tour_data.size
        #results['all_tours'] = tour_data # handle return of tours to match criteria as well
        #logger = Logger.new(STDOUT)
        #logger.info(JSON.pretty_generate(results))
        results
        end
      
        

      
      #rescue StandardError => e
        #logger.info e.message
        # halt 400
      #end
      # use check_db_tours helper to check if tour exists
      #case check_db_tours(country, country_tour_list)
      #  when 'Country does not exist'
      #    # Use the model tour.rb to create a new data.
      #    new_tour = Tour.new(country: country, tours: country_tour_list)
      #    halt 500, "Error saving tours to the database" unless new_tour.save
      #end

      # get country tour array
      #begin
       # tour_data = JSON.parse(country_tour_list)
      #rescue => e
        #e.message
      #end

      # remove tours out of the price range
     # tour_data.delete_if do |tour|
       # tour_price = tour['price'].gsub('$','').to_i
        #tour_price < tour_price_min || tour_price > tour_price_max
      #end
      # keep tours with specified categories
      #tour_data.keep_if { |tour| tour_categories.include?(tour['category']) } unless tour_categories.empty?


      #[country, tour_data.size, tour_data]
    end
    #logger.info(search_results.to_json)
    search_results


  end

end
