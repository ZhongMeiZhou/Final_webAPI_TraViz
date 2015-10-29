require_relative 'spec_helper'
require 'json'

describe 'Check if service is active' do
  it 'should return ok' do
    get '/'
    last_response.must_be :ok?
  end
end

describe 'Check if there is some data' do
  it 'should return taiwan tour list in json' do
    VCR.use_cassette('taiwan_tours') do
      get '/api/v1/taiwan_tours'
    end
    last_response.must_be :ok?
    last_response.body.wont_equal ''
  end
end

describe 'Check parameter results' do
  it 'should receive parameter and return a json' do
    VCR.use_cassette('honduras_tours') do
      get '/api/v1/tours/honduras.json'
    end
    last_response.must_be :ok?
    last_response.body.wont_equal ''
  end
end

describe 'Check bad parameter results' do
  it 'should return nothing' do
    VCR.use_cassette('zamunda_tours') do
      get '/api/v1/tours/zamunda.json'
    end
    last_response.body.must_equal ''
  end
end

describe 'Obtaining data by post parameter' do
  it 'should push a post request and return a json' do
    header = { 'CONTENT_TYPE' => 'application/json'}
    body = {
      country: 'Honduras'
    }

    VCR.use_cassette('post_tours') do
      post 'api/v1/tours', body.to_json, header
    end
    last_response.must_be :ok?
    last_response.body.wont_equal ''
  end
end
