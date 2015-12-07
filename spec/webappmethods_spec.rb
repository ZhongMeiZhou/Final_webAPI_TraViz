require_relative 'spec_helper'
require 'json'

describe 'Check complex search method' do

  it 'should return tour data with no filters' do
    header = { 'CONTENT_TYPE' => 'application/json' }
    body = {
      tour_countries: 'Honduras, Belize, Nicaragua',
      tour_categories: '',
      tour_price_min: '',
      tour_price_max: '',
    }
    VCR.use_cassette('webappmethods') do
      post '/api/v1/tour_compare', body.to_json, header
    end

    last_response.must_be :ok?
    search_results = JSON.parse(last_response.body)
    search_results.count.must_be :==, 3
    search_results.must_be_kind_of Array
    total_tours = 0
    search_results.each do |country_info|
      tour_info = country_info[2]
      total_tours += tour_info.size
    end

    total_tours.must_be :==, 42

  end

  it 'should return tour data with category filters' do
    header = { 'CONTENT_TYPE' => 'application/json' }
    body = {
      tour_countries: 'Honduras, Belize, Nicaragua',
      tour_categories: 'History & Culture, Small Group Tours',
      tour_price_min: '',
      tour_price_max: '',
    }
    VCR.use_cassette('webappmethods') do
      post '/api/v1/tour_compare', body.to_json, header
    end

    last_response.must_be :ok?
    search_results = JSON.parse(last_response.body)
    search_results.count.must_be :==, 3
    search_results.must_be_kind_of Array
    total_tours = 0
    search_results.each do |country_info|
      tour_info = country_info[2]
      total_tours += tour_info.size
    end

    total_tours.must_be :==, 36

  end

  it 'should return tour data with price filters' do
    header = { 'CONTENT_TYPE' => 'application/json' }
    body = {
      tour_countries: 'Honduras, Belize, Nicaragua',
      tour_categories: '',
      tour_price_min: '150',
      tour_price_max: '2500',
    }
    VCR.use_cassette('webappmethods') do
      post '/api/v1/tour_compare', body.to_json, header
    end

    last_response.must_be :ok?
    search_results = JSON.parse(last_response.body)
    search_results.count.must_be :==, 3
    search_results.must_be_kind_of Array
    total_tours = 0
    search_results.each do |country_info|
      tour_info = country_info[2]
      total_tours += tour_info.size
    end

    total_tours.must_be :==, 32

  end

  it 'should return tour data with all filters' do
    header = { 'CONTENT_TYPE' => 'application/json' }
    body = {
      tour_countries: 'Honduras, Belize, Nicaragua',
      tour_categories: 'Cycling, Hiking & Trekking, History & Culture, Nature & Wildlife, Sightseeing Tours, Water Sports',
      tour_price_min: '1000',
      tour_price_max: '4500',
    }
    VCR.use_cassette('webappmethods') do
      post '/api/v1/tour_compare', body.to_json, header
    end

    last_response.must_be :ok?
    search_results = JSON.parse(last_response.body)
    search_results.count.must_be :==, 3
    search_results.must_be_kind_of Array
    total_tours = 0
    search_results.each do |country_info|
      tour_info = country_info[2]
      total_tours += tour_info.size
    end

    total_tours.must_be :==, 16

  end
end
