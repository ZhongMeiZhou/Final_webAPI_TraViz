require 'sinatra/base'
require 'json'

class ApplicationController < Sinatra::Base
  helpers VisualizerAPIHelpers
  configure :production, :development do
    enable :logging
  end
  

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
      get_tours(params[:country]).to_json
    rescue StandardError => e
      logger.info e.message
      halt 400
    end
  end

  post_tours = lambda do
    content_type :json
    begin
      req = JSON.parse(request.body.read)
      list = get_tours(req['country'])

      # Save tours

      begin 
        list.each do |key, value|
          Tour.new(
            country: req['country'],
            title: key, 
            price: value
            ).save
        end

        status 201
        redirect "/api/v1/tutorials/#{req['country']}.json", 303

      rescue
        halt 500, 'Error saving Tours to the database'
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
