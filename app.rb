require 'sinatra/base'
require 'json'
require_relative './model/lonely_planet_tours.rb'

class VisualizerAPI < Sinatra::Base
  helpers do
    def get_tours(country)
      Tours.new(country)
    rescue
     halt 400
    end
  end

VERSION = '1.0.0'

get_root = lambda do
    "Version #{VERSION} is up and running. Find us on Github: https://github.com/ZhongMeiZhou/scraper_webAPI"
end

get_taiwan_tours = lambda do
  content_type :json
  get_tours('Taiwan').to_json
end

get_country_tours = lambda do
  content_type :json
  get_tours(params[:country]).to_json
end

#API Routes
get '/', &get_root
get '/api/v1/taiwan_tours', &get_taiwan_tours
get '/api/v1/tours/:country.json', &get_country_tours
end
