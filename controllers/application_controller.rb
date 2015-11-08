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
#      # Get Tours from database
#      response = {
#        "country" => params[:country].downcase ,
#        "tours" => Tour.where(["country = ?", params[:country].downcase]) }.to_json(:except => [ :id])
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
      #logger.info req
      #puts JSON.parse(list)['tours']
    rescue StandardError => e
      logger.info e.message
      halt 400
    end
    Tour.where(["country = ?", req['country'].downcase]).delete_all
    #JSON.parse(JSON.parse(list)['tours']).each do |tour|
    db_tour = Tour.new(country: req['country'].downcase, tours: JSON.parse(list)['tours'])
    #title: tour['title'].gsub(/\r/," ").to_s,
    #price: 100.3 #tour['price'].gsub(/\r/," ").to_f)
    #end
    if db_tour.save
      status 201
      redirect "/api/v1/tours/#{db_tour.id}", 303
      #rescue Exception => e
      #  halt 500, "Error saving Tours to the database., #{e.message} ,#{e.backtrace}"
    else
      halt 500, "Error saving Tours to the database"
    end
  end

  get_tour_id = lambda do
      content_type :json
      begin
        tour= Tour.find(params[:id])
        country = tour.country
        tours = tour.tours
        #title = tour.title
        #price = tour.price
        logger.info({ id: tour.id, country: country }.to_json)
        { id: tour.id, country: country, tours: tours}.to_json
          #title: title, price: price}.to_json
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
