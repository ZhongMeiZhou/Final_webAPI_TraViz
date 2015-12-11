ENV['RACK_ENV'] = 'test'

Dir.glob('./{models,helpers,controllers}/*.rb').each { |file| require file }
require 'minitest/autorun'
require 'rack/test'
require 'vcr'
require 'webmock/minitest'
#require 'capybara-webkit'
#require 'capybara'

include Rack::Test::Methods
#include WebMock::API
#stub_request( :any, /:3000\// ).to_rack( ApplicationController )

def app
  ApplicationController
end

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
end

#Capybara.app = app
