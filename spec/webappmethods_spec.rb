require_relative 'spec_helper'
require 'json'

describe 'Check method used by webapp' do
  it 'should return parameters received' do
    header = { 'CONTENT_TYPE' => 'application/json' }
    body = {
      tour_countries: 'Honduras, Nicaragua, Belize',
      tour_categories: 'Outdoors, Mayan, Colonial, Extreme',
      tour_price_min: 25,
      tour_price_max: 675,
    }
    VCR.use_cassette('webappmethods') do
      post '/api/v1/tour_compare', body.to_json, header
    end
  

    #last_response.body.must_be_kind_of String
    #last_response.body.must_match(/Please search for tours of type/)

    last_response.must_be :ok?
  end

end
