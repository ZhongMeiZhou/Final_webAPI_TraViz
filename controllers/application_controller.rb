require 'sinatra/base'
require 'json'
require './helpers/app_helper'
require './models/tour'

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

    #remove existing tour details for country if exists to update with latest results
    #may be more efficient to compare results rather than rewriting data that may be the same
    #Tour.where(["country = ?", country]).delete_all
    #check_if_exists = Tour.where(["country = ?", country])

    db_tour = Tour.new(country: country, tours: only_tours)

    if db_tour.save
      status 201
      redirect "/api/v1/tours/#{db_tour.id}", 303
    else
      halt 500, "Error saving tours to the database"
    end
  end

  get_tour_id = lambda do
      content_type :json
      begin
        tour= Tour.find(params[:id])
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
