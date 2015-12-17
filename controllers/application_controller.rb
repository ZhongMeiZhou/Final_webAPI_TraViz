require 'sinatra/base'
require 'sinatra/flash'
#require 'httparty'
require 'hirb'
#require 'slim'
require 'json'
require 'config_env'
require 'aws-sdk'
require_relative '../helpers/init'
require_relative '../services/init'
#require './models/tour'
#require './forms/tour_form'


class APITraViz < Sinatra::Base
  helpers LP_APIHelpers
  enable :sessions
  #register Sinatra::Flash
  use Rack::MethodOverride

  #set :views, File.expand_path('../../views', __FILE__)
  #set :public_folder, File.expand_path('../../public', __FILE__)

  configure do
    Hirb.enable
    set :session_secret, 'zmz!'
    set :api_ver, 'api/v2'
  end

  configure :development, :test do
    enable :logging
    set :api_server, 'http://localhost:3000'
    ConfigEnv.path_to_config("#{__dir__}/../config/config_env.example.rb")
  end


  #configure :production do
  #  set :api_server, 'http://zmztours.herokuapp.com'
  #end

  configure :production do
    enable :logging
  end


  get_root = lambda do
    "ZMZ Traviz API Service, #{settings.api_ver}"
  end

  # API Lambdas

  #Call the service check_tour
  get_country_tours = lambda do
    content_type :json
    #begin
      tours = CheckTours.new.call(params[:country])
    #rescue => e
      tours.nil? ? halt(404) : tours
      #halt 404, e.message
    #end
  end

  # Use the app_helper to get the data from DB
  get_tour_id = lambda do
    content_type :json
    tour_list = tour_finder(params[:id])
    tour_list.nil? ? halt(404) : tour_list
  end

  check_tours = lambda do
    content_type :json
    begin
      req = JSON.parse(request.body.read)
      country = req['country'].strip.downcase
      country_tours_data = CheckTours.new.call(country)
      country_tours_data.nil? ? halt(404) : only_tours = JSON.parse(country_tours_data)['tours']
      #scraped_list = get_tours(country).to_json
    rescue => e
      logger.info e.message
      halt 400
    end
    # use app_helper to get the id of the country from existing data or create new one.
    begin
      id = get_country_id(country, only_tours)
    rescue => e
      logger.info e.message
      halt 500, e.message
    end
    redirect "/#{settings.api_ver}/tours/#{id}", 303
  end

  tour_compare = lambda do
    content_type :json
    req = JSON.parse(request.body.read)
    CompareTours.new.call(req)
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
