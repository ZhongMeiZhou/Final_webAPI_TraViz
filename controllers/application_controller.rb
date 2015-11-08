require 'sinatra/base'
require 'json'

class ApplicationController < Sinatra::Base
  
  configure :production, :development do
    enable :logging
  end

  helpers VisualizerAPIHelpers
  

  get_root = lambda do
    "Version #{VERSION} is up and running. Find us on <a href='https://github.com/ZhongMeiZhou/scraper_webAPI' target='_blank'>Github.</a>"
  end

  get_taiwan_tours = lambda do
    content_type :json
    get_tours('Taiwan').to_json
  end

  get_country_tours = lambda do
    content_type :json
    begin
      # Get Tours from database
      Tour.where(["country = ?", params[:country].downcase]).to_json
    rescue StandardError => e
      logger.info e.message
      halt 400
    end
  end

  post_tours = lambda do
    content_type :json
    begin
      req = JSON.parse(request.body.read)
      list = get_tours(req['country']).to_json
      puts JSON.parse(list)['tours']


      # Save tours

      begin 
        #delete before
        Tour.where(["country = ?", req['country'].downcase]).delete_all
        JSON.parse(JSON.parse(list)['tours']).each do |key, value|
          Tour.new(
            country: req['country'].downcase,
            title: key.to_s, 
            price: value
            ).save
          
        end

        status 201
        redirect "/api/v1/tutorials/#{req['country']}.json", 303

      rescue Exception => e
        halt 500, "Error saving Tours to the database., #{e.message} ,#{e.backtrace}"
      end
    rescue StandardError => e
      logger.info e.message
      halt 400
    end
  end

  # API Routes
  get '/', &get_root
  get '/api/v1/taiwan_tours', &get_taiwan_tours
  get '/api/v1/tours/:country.json', &get_country_tours
  post '/api/v1/tours', &post_tours
end
