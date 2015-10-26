require_relative 'spec_helper'
require 'json'

describe "Check if service root is valid" do
  it "should return ok and body should include Github repo" do
    get '/'
    last_response.must_be :ok?
    last_response.body.must_match(/ZhongMeiZhou/)
  end
end

describe "Getting tour details" do
  CONTENT_TYPE = 'application/json'

  it "should return taiwan tour list in JSON format" do
    VCR.use_cassette('taiwan_tours') do
      get '/api/v1/taiwan_tours'
    end
    last_response.must_be :ok?
    last_response.headers['Content-Type'].must_equal CONTENT_TYPE
  end

  it "should return tour list based on country specified" do
    VCR.use_cassette('honduras_tours') do
      get '/api/v1/tours/honduras.json'
    end
    last_response.must_be :ok?
    last_response.headers['Content-Type'].must_equal CONTENT_TYPE
  end

  it "should return 400 for unknown country tour requests" do
    VCR.use_cassette('zamunda_tours') do
      get '/api/v1/tours/zamunda.json'
    end
    last_response.status.must_equal 400
  end
end
