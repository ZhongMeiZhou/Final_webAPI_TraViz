require 'sinatra/base'
require 'json'
require './helpers/app_helper'

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
      get_tours(req['country']).to_json
    rescue StandardError => e
      logger.info e.message
      halt 400
    end

    tour = Tour.new(
      country: req['country'],
      tours:  req['tours'].to_json
      )

    if tour.save
      status 201
      redirect "http://www.lonelyplanet.com/#{tour.country}/tours", 303
    else
      halt 500, 'Error saving tour request to database'
    end

  end

  # API Routes
  get '/', &get_root
  get '/api/v1/taiwan_tours', &get_taiwan_tours
  get '/api/v1/tours/:country.json', &get_country_tours
  post '/api/v1/tours', &post_tours
end
