require 'sinatra/base'
require 'sinatra/flash'
require 'httparty'
require 'hirb'
require 'slim'
require 'json'
require './helpers/app_helper'
require './models/init'
require './services/init'
#require './forms/tour_form'

class ApplicationController < Sinatra::Base
  helpers LP_APIHelpers # include helpers
  include CheckTours # service defined to check tours in db
  include GetTours # service defined to get tours from lonely planet gem

  #enable :sessions
  #register Sinatra::Flash
  #use Rack::MethodOverride
  #set :views, File.expand_path('../../views', __FILE__)
  #set :public_folder, File.expand_path('../../public', __FILE__)

  configure do
    Hirb.enable
    #set :session_secret, 'zmz!'
    set :api_ver, 'api/v1'
  end

  configure :development,:test do
    set :api_server, 'http://localhost:3000'
  end

  configure :production do
    set :api_server, 'http://zmztours.herokuapp.com'
  end

  configure :production, :development do
    enable :logging
  end


  get_root = lambda do
    "ZMZ Traviz API Service"
  end

  # may not be used if we are not adding functionality to search for one country
  get_country_tours = lambda do
    content_type :json
    begin
      get_tours_by_country(params[:country]).to_json
    rescue StandardError => e
      logger.info e.message
      halt 400
    end
  end

  # may not be used if we are not adding functionality to search for one country
  get_tour_id = lambda do
    content_type :json
    begin
      tour = Tour.find(params[:id])
      country = tour.country
      tours = tour.tours
      logger.info({ id: tour.id, country: country }.to_json)
      { id: tour.id, country: country, tours: tours}.to_json
    rescue
      halt 400
    end
  end

  check_tours = lambda do
    content_type :json

    begin
      req = JSON.parse(request.body.read)
      logger.info req
      country = req['country'].strip.downcase
      scraped_list = get_tours_by_country(country).to_json
      only_tours = JSON.parse(scraped_list)['tours']
    rescue StandardError => e
      logger.info e.message
      halt 400
    end

    resultset = Tour.where(["country = ?", country]).first

    case check_db_tours(resultset, country, only_tours)
    when 'Record exists'
      id = resultset.id
      redirect "/#{settings.api_ver}/tours/#{id}", 303

    when 'Record exists but tour details changed'
      tour = Tour.find_by(country: country)
      tour.tours = only_tours
      if tour.save
        status 201
        redirect "/#{settings.api_ver}/tours/#{tour.id}", 303
      else
        halt 500, "Error updating tour details"
      end

    when 'Country does not exist'
      db_tour = Tour.new(country: country, tours: only_tours)
      if db_tour.save
        status 201
        redirect "/#{settings.api_ver}/tours/#{db_tour.id}", 303
      else
        halt 500, "Error saving tours to the database"
      end
    else
    end
  end


  tour_compare = lambda do
    content_type :json

    req = JSON.parse(request.body.read)
    logger.info req
    country_arr = !req['tour_countries'].nil? ? req['tour_countries'] : []
    tour_categories = !req['tour_categories'].nil? ? req['tour_categories'] : []
    tour_price_min = !req['tour_price_min'].nil? ? req['tour_price_min'].to_i : 0
    tour_price_max = !req['tour_price_max'].nil? ? req['tour_price_max'].to_i : 99999

    search_results = country_arr.each_with_index.map do |country,*|
      results = Hash.new
      data = []

      begin
       country_search = get_tours_by_country(country).to_json
       country_tour_list = JSON.parse(country_search)['tours']
       check_if_exists = Tour.where(["country = ?", country]).first
      rescue StandardError => e
       logger.info e.message
       halt 400
      end

      # use check_db_tours service to run tour checks against DB
      case check_db_tours(check_if_exists, country, country_tour_list)
        when 'Country does not exist'
          new_tour = Tour.new(country: country, tours: country_tour_list)
          halt 500, "Error saving tours to the database" unless new_tour.save

        when 'Record exists but tour details changed'
          tour = Tour.find_by(country: country)
          tour.tours = country_tour_list
          halt 500, "Error updating tour details" unless tour.save
      end

      # build object for use in column chart visualization, revise to count based on price and category
      # SAMPLE result: [{country: 'Belize', data: [['History', 4],['Cycling', 4]]},...]

      results['country'] = country
      tour_data = JSON.parse(Tour.find_by_country(country).tours)
       
       CATEGORIES.map do |category|
       num_per_category = 0
       num_per_category = tour_data.select do |h|
        h['category'] == category && price_in_range(strip_price(h['price']), 0, 90000)
       end.count
       results['data'] = data.push([category, num_per_category])
      end
      #results['total_tours'] = tour_data.size
      #results['all_tours'] = tour_data


      # remove tours out of the price range
      #tour_data.delete_if do |tour|
        #tour_price = tour['price'].gsub('$','').to_i
        #tour_price < tour_price_min || tour_price > tour_price_max
      #end
      # keep tours with specified categories
      #tour_data.keep_if { |tour| tour_categories.include?(tour['category']) } unless tour_categories.empty?
      logger.info(JSON.pretty_generate(results))
      results
    end

    search_results.to_json
  end

  # API Routes
  get '/', &get_root
  get "/#{settings.api_ver}/tours/:country.json", &get_country_tours
  get "/#{settings.api_ver}/tours/:id", &get_tour_id
  post "/#{settings.api_ver}/tours", &check_tours
  post "/#{settings.api_ver}/tour_compare", &tour_compare
end


=begin
  #GUI functionality removed

  get_root = lambda do
    slim :home
  end

  get_tour_search = lambda do
    slim :tours
  end

  post_tours = lambda do
    request_url = "#{settings.api_server}/#{settings.api_ver}/tours"

    # country = params[:tour]
    # body = { country: country }

    submit = TourForm.new
    submit.country = params[:tour]

    if submit.valid? == false
      flash[:notice] = 'You broke it!'
      redirect "/tours"
    end

    options = {
      body: submit.to_json,
      headers: { 'Content_Type' => 'application/json'}
    }

    results = HTTParty.post(request_url, options)

    if (results.code != 200)
      flash[:notice] = 'The Pony Express did not deliver the goods.'
      redirect "/tours"
      return nil
    end

    id = results.request.last_uri.path.split('/').last
    session[:results] = results.to_json
    session[:action] = :create
    redirect "/tours/#{id}" # <= new route by Bayardo
  end

  get_tours = lambda do
    if session[:action] == :create
      @results = JSON.parse(session[:results])
    else
      request_url = "#{settings.api_server}/#{settings.api_ver}/tours/#{params[:id]}"
      options = { headers: { 'Content-Type' => 'application/json'}}
      begin
        @results = HTTParty.get(request_url,options)
      rescue StandardError => e
        logger.info e.message
        halt 400, e.message
      end

      if @results.code != 200
        flash[:notice] = "Cannot find any tours for #{params[:country]}"
        redirect "/#{settings.api_ver}/tours"
      end
    end
    @id = params{:id}
    @action = :update
    @country = @results['country'].upcase
    @tours = JSON.parse(@results['tours'])

    slim :tours
  end

  # GUI Routes
  get '/', &get_root
  get "/tours", &get_tour_search
  post "/tours", &post_tours
  get '/tours/:id', &get_tours
=end

