ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'vcr'
require 'webmock/minitest'
require_relative '../application_controller'

include Rack::Test::Methods

def app
  ApplicationController
end

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
end
