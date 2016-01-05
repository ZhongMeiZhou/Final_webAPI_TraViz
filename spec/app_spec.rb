require_relative '../helpers/init'
require_relative 'spec_helper'
require 'json'

describe 'Check if service root is valid' do
  it 'should return ok' do
    get '/'
    last_response.must_be :ok?
    last_response.body.must_match(/ZMZ/i)
  end
end

describe 'Getting tour listings' do
  CONTENT_TYPE = 'application/json'

  it 'should receive parameter and return a json' do
    #VCR.use_cassette('honduras_tours') do
      get "/api/v2/tours/honduras.json"
    #end
    last_response.must_be :ok?
    last_response.headers['Content-Type'].must_equal CONTENT_TYPE
  end

  it 'should return 404 for unknown country tour request' do
    #VCR.use_cassette('zamunda_tours') do
      get '/api/v2/tours/zamunda.json'
    #end
    last_response.status.must_equal 404
  end
end

describe 'checking country tours from DB' do
  it 'should find country tour information in DB' do
    header = { 'CONTENT_TYPE' => 'application/json' }
    body = { country: 'belize' }

      # Check redirect URL from post request
    #VCR.use_cassette('tours_happy') do
      post '/api/v2/tours', body.to_json, header
      last_response.must_be :redirect?
      next_location = last_response.location
      next_location.must_match /api\/v2\/tours\/.+/

      # Check if request parameters are stored in ActiveRecord data store
      tour_id = next_location.scan(/tours\/(.+)/).flatten[0] #[/([^\/]+)$/]
      #tour_id = "76870dd2-ac7d-4a18-8d3c-d33280eaa231"
      save_tour = Tour.find_by_tour_id(tour_id)
      save_tour.country.must_equal body[:country]

      # Check if redirect works
      follow_redirect!
      last_request.url.must_match %r{api\/v2\/tours\/\d+}

      #Check if redirected response has results
      last_response.body.wont_equal ''
      JSON.parse(last_response.body).count.must_be :>, 0
    #end
  end

  it 'should return 404 for unknown countries' do
    header = { 'CONTENT_TYPE' => 'application/json' }
    body = {country: 'zamunda'}

    post '/api/v2/tours', body.to_json, header
    last_response.must_be :not_found?
  end

  it 'should return 400 for bad JSON formatting' do
    header = { 'CONTENT_TYPE' => 'application/json' }
    body = 'abcdefghijklmnopqrstuvwz'

    post '/api/v2/tours', body, header
    last_response.must_be :bad_request?
  end
end

describe 'Check complex search method' do

  it 'should return tour data with required country filter' do
    header = { 'CONTENT_TYPE' => 'application/json' }
    body = {
      tour_countries: ['Honduras', 'Belize', 'Nicaragua'], #tour_countries: ['Honduras', 'Belize', 'Nicaragua'],
      tour_categories: [],
      inputPriceRange: '0;999999' # by default will have values unlike country and category
    }
    #VCR.use_cassette('webappmethods') do
      post '/api/v2/tour_compare', body.to_json, header
    #end

    last_response.must_be :ok?
    last_response.body.wont_equal ''
    search_results = JSON.parse(last_response.body)
    search_results.count.must_be :>, 0

  end

  it 'should return tour data with country and category filters' do
    header = { 'CONTENT_TYPE' => 'application/json' }
    body = {
      tour_countries: ['Honduras', 'Belize', 'Nicaragua'],
      tour_categories: ['History & Culture', 'Small Group Tours'],
      inputPriceRange: '0;999999'
    }
    #VCR.use_cassette('webappmethods') do
      post '/api/v2/tour_compare', body.to_json, header
    #end

    last_response.must_be :ok?
    last_response.body.wont_equal ''
    search_results = JSON.parse(last_response.body)
    search_results.count.must_be :>, 0

  end

  it 'should return tour data with all filters' do
    header = { 'CONTENT_TYPE' => 'application/json' }
    body = {
      tour_countries: ['Honduras', 'Belize', 'Nicaragua'],
      tour_categories: ['Small Group Tours', 'Adventure', 'Sightseeing', 'Health & Wellness', 'History & Culture', 'Water Sports', 'Short Break', 'Cycling', 'Nature & Wildlife', 'Holidays, Festivals & Seasonal'],
      inputPriceRange: '0;999999'
    }
    #VCR.use_cassette('webappmethods') do
      post '/api/v2/tour_compare', body.to_json, header
    #end

    last_response.must_be :ok?
    last_response.body.wont_equal ''
    search_results = JSON.parse(last_response.body)
    search_results.count.must_be :>, 0

  end
end
