require_relative './check_tour'
require_relative '../helpers/app_helper'

class CompareTours
  include LP_APIHelpers
  def call (req)
    country_arr = !req['tour_countries'].nil? ? req['tour_countries'].split(', ') : []
    tour_categories = !req['tour_categories'].empty? ? req['tour_categories'].split(', ') : []
    tour_price_min = !req['tour_price_min'].empty? ? req['tour_price_min'].to_i : 0
    tour_price_max = !req['tour_price_max'].empty? ? req['tour_price_max'].to_i : 99999
    tour_comparison = countries_tours(country_arr, tour_categories, tour_price_min, tour_price_max)
    tour_comparison.to_json
  end

  private

  def countries_tours(country_arr, tour_categories, tour_price_min, tour_price_max)
    search_results = country_arr.map do |country|
      #begin
        country_search = CheckTours.new.call(country)
        country_tour_list = JSON.parse(country_search)['tours']
        id = get_country_id(country, country_tour_list)
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
        tour_data = JSON.parse(country_tour_list)
      #rescue => e
        #e.message
      #end

      # remove tours out of the price range
      tour_data.delete_if do |tour|
        tour_price = tour['price'].gsub('$','').to_i
        tour_price < tour_price_min || tour_price > tour_price_max
      end
      # keep tours with specified categories
      tour_data.keep_if { |tour| tour_categories.include?(tour['category']) } unless tour_categories.empty?
      [country, tour_data.size, tour_data]
    end
    #logger.info(search_results.to_json)
    search_results
  end

end
