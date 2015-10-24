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

    get '/' do #current API version and github homepage
      "Version #{VERSION} is up and running. Find us on Github: https://github.com/ZhongMeiZhou/scraper_webAPI"
    end

    get '/api/v1/taiwan_tours' do
      content_type :json
      get_tours('Taiwan').to_json
    end

    get '/api/v1/tours/:country.json' do
      content_type :json
      get_tours(params[:country]).to_json
      #takes a url parameter and returns json
    end
end
