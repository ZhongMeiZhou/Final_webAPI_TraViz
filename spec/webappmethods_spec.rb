require_relative 'spec_helper'
require 'json'

describe 'Check complex search method' do

  it 'should return tour data with filters' do
    header = { 'CONTENT_TYPE' => 'application/json' }
    body = {
      tour_countries: 'Honduras, Nicaragua, Belize',
      tour_categories: '',
      tour_price_min: 0,
      tour_price_max: 300,
    }
    VCR.use_cassette('webappmethods') do
      post '/api/v1/tour_compare', body.to_json, header
    end

    last_response.must_be :ok?
    search_results = JSON.parse(last_response.body)
    search_results.count.must_be :>, 0
    search_results.must_be_kind_of Array
  end

end
