require 'sinatra'
require 'json'

class VisualizerAPI < Sinatra::Base

VERSION = '0.1.0'

get '/' do #current API version and github homepage
  "Version #{VERSION} is up and running. Find us on Github: https://github.com/ZhongMeiZhou/scraper_webAPI"
end

get '/api/v1/taiwan_tours' do
  #returns a json using the gem.
end

get '/api/v1/tours' do
  #takes a url parameter and returns json
end

end
