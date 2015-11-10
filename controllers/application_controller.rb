require 'sinatra/base'
require 'sinatra/flash'
require 'httparty'
require 'hirb'
require 'slim'
require 'json'
require './helpers/app_helper'
require './models/tour'

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

  configure :development, :test do
    set :api_server, 'http://localhost:9292'
  end

  configure :production do
    set :api_server, 'http://zmztours.herokuapp.com'
  end

  configure :production, :development do
    enable :logging
  end

  get_root = lambda do
    slim :home
  end

  get_taiwan_tours = lambda do
    content_type :json
    get_tours('taiwan').to_json
  end

  get_country_tours = lambda do
    content_type :json
    begin
      get_tours(params[:country]).to_json
    rescue StandardError => e
      logger.info e.message
      halt 400
    end
  end

  # added routes
  post_tours = lambda do
    content_type :json
    begin
      req = JSON.parse(request.body.read)
      logger.info req
      country = req['country'].downcase
      scraped_list = get_tours(country).to_json
      only_tours = JSON.parse(scraped_list)['tours']
    rescue StandardError => e
      logger.info e.message
      halt 400
    end

    #Tour.where(["country = ?", country]).delete_all
    check_if_exists = Tour.where(["country = ?", country]).first

    #if country tour details has not changed then show existing DB results
    if check_if_exists && check_if_exists.country == country && check_if_exists.tours == only_tours
      id = check_if_exists.id
      redirect "/api/v1/tours/#{id}", 303
    else
      #if tours has changed just update the tour details
      if check_if_exists && check_if_exists.tours != only_tours && check_if_exists.country == country
        tour = Tour.find_by(country: country)
        tour.tours = only_tours
        if tour.save
          status 201
          redirect "/api/v1/tours/#{tour.id}", 303
        else
          halt 500, "Error updating tour details"
        end
      else # if country not yet exists in the DB, save it
        db_tour = Tour.new(country: country, tours: only_tours)
        if db_tour.save
          status 201
          redirect "/api/v1/tours/#{db_tour.id}", 303
        else
          halt 500, "Error saving tours to the database"
        end
      end
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

  # API Routes
  get '/', &get_root
  get '/api/v1/taiwan_tours', &get_taiwan_tours
  get '/api/v1/tours/:country.json', &get_country_tours
  get '/api/v1/tours/:id', &get_tour_id
  post '/api/v1/tours', &post_tours
end
