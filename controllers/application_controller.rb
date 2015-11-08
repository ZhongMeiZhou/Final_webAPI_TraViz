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

  # revised GET route
  get_country_tours = lambda do
    content_type :json
    begin
      country = params[:country].downcase
      post = Tour.where(["country = ?", country])

      # if atleast one tour exists use db results or else scrape for results
      if !post.empty?
      response = { 
        "country" => country,
        "tours" => post
        }.to_json(:except => [:id,:created_at,:updated_at,:country])
      else
        response = get_tours(country).to_json
      end

    rescue StandardError => e
      logger.info e.message
      halt 400
    end
  end


  post_tours = lambda do
    content_type :json
    begin
      req = JSON.parse(request.body.read)
      country = req['country'].downcase
      list = get_tours(country).to_json
      puts JSON.parse(list)['tours']

      # Save tours
      begin 
        #delete before
        Tour.where(["country = ?", country]).delete_all
        JSON.parse(JSON.parse(list)['tours']).each do |tour|
          
          Tour.new(
            country: country,
            title: tour['title'].to_s.gsub(/\r/," "), #check encoding, some characters not shown properly
            price: tour['price'] #price not converting properly, saving as 0.00, check why!
            ).save
          
        end
        status 201
        redirect "/api/v1/tours/#{country}.json", 303
      rescue Exception => e
        halt 500, "Error saving tour to the database., #{e.message} ,#{e.backtrace}"
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
