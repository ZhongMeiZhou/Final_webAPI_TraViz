require_relative 'spec_helper'
require 'json'


describe 'Check if service root is valid' do
  it 'should return ok' do
    get '/'
    last_response.must_be :ok?
    last_response.body.must_match(/ZhongMeiZhou/)
  end
end

describe 'Getting tour listings' do
  CONTENT_TYPE = 'application/json'

  it 'should return taiwan tour list in json' do
    VCR.use_cassette('taiwan_tours') do
      get '/api/v1/taiwan_tours'
    end
    last_response.must_be :ok?
    last_response.headers['Content-Type'].must_equal CONTENT_TYPE
  end

  it 'should receive parameter and return a json' do
    VCR.use_cassette('honduras_tours') do
      get '/api/v1/tours/honduras.json'
    end
    last_response.must_be :ok?
    last_response.headers['Content-Type'].must_equal CONTENT_TYPE
  end

  it 'should return 404 for unknown country tour request' do
    VCR.use_cassette('zamunda_tours') do
      get '/api/v1/tours/zamunda.json'
    end
    last_response.status.must_equal 404
  end
end

#describe 'checking posts requests' do
#  header = {'CONTENT-TYPE' => 'application/json'}

#  it 'should push a post request and return a json' do
#    body = {country: 'Honduras'}
#    VCR.use_cassette('post_tours') do
#      post 'api/v1/tours', body.to_json, header
#    end
#    last_response.must_be :ok?
#    last_response.body.wont_equal ''
#  end

#  it 'should return 400 for bad json formatting' do
#    body = 'abcdefghijklmnopqrstuvwz'
#    post '/api/v1/tours', body, header
#    last_response.must_be :bad_request?
#  end

#  it 'should return 404 for unknown country' do
#    body = {country: 'zamunda'}
#    VCR.use_cassette('post_zamunda') do
#      post '/api/v1/tours', body.to_json, header
#    end
#    last_response.status.must_equal 404
#  end

#end

describe 'checking country tours from DB' do
  it 'should find country tour information in DB' do
    header = { 'CONTENT_TYPE' => 'application/json' }
    body = { country: 'belize' }

    # Check redirect URL from post request
    VCR.use_cassette('tours_happy') do
      post '/api/v1/tours', body.to_json, header
      last_response.must_be :redirect?
      next_location = last_response.location
      next_location.must_match %r{api\/v1\/tours\/\d+}

      #Check if request parameters are stored in ActiveRecord data store
      tour_id = next_location.scan(%r{tours\/(\d+)}).flatten[0].to_i
      save_tour = Tour.find(tour_id)
      save_tour.country.must_equal body[:country]

      # Check if redirect works
      follow_redirect!
      last_request.url.must_match %r{api\/v1\/tours\/\d+}

      #Check if redirected response has results
      last_response.body.wont_equal ''
      JSON.parse(last_response.body).count.must_be :>, 0
    end
  end

    it 'should return 404 for unknown countries' do
        header = { 'CONTENT_TYPE' => 'application/json' }
        body = {country: 'zamunda'}

        post '/api/v1/tours', body.to_json, header
        last_response.must_be :not_found?
      end

      it 'should return 400 for bad JSON formatting' do
        header = { 'CONTENT_TYPE' => 'application/json' }
        body = 'abcdefghijklmnopqrstuvwz'

        post '/api/v1/tours', body, header
        last_response.must_be :bad_request?
      end

  end
