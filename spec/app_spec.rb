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

describe 'checking posts requests' do
  header = {'CONTENT-TYPE' => 'application/json'}

  it 'should push a post request and return a json' do
    body = {country: 'Honduras'}
    VCR.use_cassette('post_tours') do
      post 'api/v1/tours', body.to_json, header
    end
    last_response.must_be :ok?
    last_response.body.wont_equal ''
  end

  it 'should return 400 for bad json formatting' do
    body = 'abcdefghijklmnopqrstuvwz'
    post '/api/v1/tours', body, header
    last_response.must_be :bad_request?
  end

  it 'should return 404 for unknown country' do
    body = {country: 'zamunda'}
    VCR.use_cassette('post_zamunda') do
      post '/api/v1/tours', body.to_json, header
    end
    last_response.status.must_equal 404
  end

end
