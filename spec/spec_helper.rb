ENV['RACK_ENV'] = 'test'

Dir.glob('./{controllers, models, helpers}/*.rb').each { |file| require file }
require 'minitest/autorun'
require 'rack/test'
require 'vcr'
require 'webmock/minitest'

include Rack::Test::Methods

def app
  ApplicationController
end

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
end
