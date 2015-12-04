require 'sinatra/base'
require 'sinatra/flash'
require 'httparty'
require 'hirb'
require 'slim'
require 'json'
require './helpers/app_helper'
require './models/tour'
require './forms/tour_form'

class ApplicationController < Sinatra::Base
  helpers VisualizerAPIHelpers
  enable :sessions
  register Sinatra::Flash
  use Rack::MethodOverride

  set :views, File.expand_path('../../views', __FILE__)
  set :public_folder, File.expand_path('../../public', __FILE__)

  configure do
    Hirb.enable
    set :session_secret, 'zmz!'
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

  # API
  # API Lambdas
  get_country_tours = lambda do
    content_type :json
    begin
      get_tours(params[:country]).to_json
    rescue StandardError => e
      logger.info e.message
      halt 400
    end
  end

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
      scraped_list = get_tours(country).to_json
      only_tours = JSON.parse(scraped_list)['tours']
    rescue StandardError => e
      logger.info e.message
      halt 400
    end

    check_if_exists = Tour.where(["country = ?", country]).first

    #if country tour details has not changed then show existing DB results
    if check_if_exists && check_if_exists.country == country && check_if_exists.tours == only_tours
      id = check_if_exists.id
      redirect "/#{settings.api_ver}/tours/#{id}", 303
    else
      #if tours has changed just update the tour details
      if check_if_exists && check_if_exists.tours != only_tours && check_if_exists.country == country
        tour = Tour.find_by(country: country)
        tour.tours = only_tours
        if tour.save
          status 201
          redirect "/#{settings.api_ver}/tours/#{tour.id}", 303
        else
          halt 500, "Error updating tour details"
        end
      else # if country not yet exists in the DB, save it
        db_tour = Tour.new(country: country, tours: only_tours)
        if db_tour.save
          status 201
          redirect "/#{settings.api_ver}/tours/#{db_tour.id}", 303
        else
          halt 500, "Error saving tours to the database"
        end
      end
    end

  end

  tour_compare = lambda do
    content_type :json

    req = JSON.parse(request.body.read)
    logger.info req
    tour_countries = req['tour_countries']
    tour_categories = req['tour_categories']
    tour_price_min = req['tour_price_min']
    tour_price_max = req['tour_price_max']

    # "Please search for tours of type #{tour_categories} in the following countries #{tour_countries} between $#{tour_price_min} and $#{tour_price_max}. Thanks!"

    country_arr = tour_countries.split(', ')

    country_arr.each do |country|
      check_if_exists = Tour.where(["country = ?", country]).count

      if check_if_exists == 0 # if country not yet exists in the DB, save it
          country_search = get_tours(country).to_json
          country_tour_list = JSON.parse(country_search)['tours']
          new_tour = Tour.new(country: country, tours: country_tour_list)
          halt 500, "Error saving tours to the database" unless new_tour.save
      end

    
    end

  end

  # API Routes
  get "/#{settings.api_ver}/tours/:country.json", &get_country_tours
  get "/#{settings.api_ver}/tours/:id", &get_tour_id
  post "/#{settings.api_ver}/tours", &check_tours
  post "/#{settings.api_ver}/tour_compare", &tour_compare

  # GUI Lambdas
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

end
