require_relative 'spec_helper'
require 'json'

describe "Check if service root is valid" do
  it "should return ok and body should include Github repo" do
    get '/'
    last_response.must_be :ok?
    last_response.body.must_match(/ZhongMeiZhou/)
  end
end

describe "Getting tour listings" do
  CONTENT_TYPE = 'application/json'
  
  it "should return JSON formatted taiwan tour listings" do
    VCR.use_cassette('taiwan_tours') do
      get '/api/v1/taiwan_tours'
    end
    last_response.must_be :ok?
    last_response.headers['Content-Type'].must_equal CONTENT_TYPE
  end

  it "should return JSON formatted tour listings based on specified country" do
    VCR.use_cassette('honduras_tours') do
      get '/api/v1/tours/honduras.json'
    end
    last_response.must_be :ok?
    last_response.headers['Content-Type'].must_equal CONTENT_TYPE
  end

  it "should return 404 for unknown country tour requests" do
    VCR.use_cassette('zamunda_tours') do #zamunda is a fictional country name
      get '/api/v1/tours/zamunda.json'
    end
    last_response.status.must_equal 404
  end
end

describe 'Checking post requests' do
  header = {'CONTENT_TYPE' => 'application/json'}

  it "should return 400 for bad JSON formatting" do
    body = 'abcdefghijklmnopqwyu'
    post '/api/v1/check', body, header
    last_response.must_be :bad_request?
  end

  it "should return 404 for unknown country" do
    body = {country: 'zamunda'}
    VCR.use_cassette('post_zamunda') do #zamunda is a fictional country name
      post '/api/v1/check', body.to_json, header
    end
    last_response.status.must_equal 404
    #last_response.must_be :not_found?
  end
end
