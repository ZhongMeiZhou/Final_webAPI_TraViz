require_relative 'spec_helper'
require 'json'
require "minitest-capybara"

class AcceptanceSpec < Minitest::Spec
  include Capybara::DSL
  include Capybara::Assertions
end

class ViewTest < AcceptanceSpec

  describe 'Search Tours View',:type => :feature do

  	it 'should return to link /api/v[:current_version]/tours/:id' do
	  	visit '/tours'
	   	fill_in 'tour', with: 'Taiwan'
	  	VCR.use_cassette('view_post_tours') do
	   		find("#btn_search").click
	   		page.current_path.must_match '/tours/1'
	  	end	
  	end

  	it 'should show more than one results' do
	   	VCR.use_cassette('view_taiwan_tours') do
	   		visit '/tours/1'
	  		assert_includes(page.body.to_s, 'Tours')
	  	end	
  	end

	end
end