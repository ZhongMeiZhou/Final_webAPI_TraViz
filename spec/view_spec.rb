require_relative 'spec_helper'
require 'json'
require "minitest-capybara"



class AcceptanceSpec < Minitest::Spec
  include Capybara::DSL
  include Capybara::Assertions
end

class ViewTest < AcceptanceSpec

	stub_request(:any, /.*localhost:3000.*/)
  describe 'Search Tours View',:type => :feature do


  	it 'should return to link /api/v[:current_version]/tours/:id' do
	   #  visit '/tours'
	   #  fill_in 'tour', with: 'Taiwan'

	   #  VCR.use_cassette('view_post_tours') do
	   #  	find('#btn_search').click
	  	# end

	  	visit '/tours'
	   	fill_in 'tour', with: 'Taiwan'
	  	VCR.use_cassette('tours_happy') do
	   		find("#btn_search").click
	  		assert_includes(page.body.to_s, 'belize')
	  	end
	  	
  	end
	end
end