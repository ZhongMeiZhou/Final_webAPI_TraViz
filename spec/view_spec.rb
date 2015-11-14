require_relative 'spec_helper'
require 'json'
require 'watir'
require 'watir-webdriver'

describe 'Check if search is redirecting to espected route' do
  it 'should return to link /api/v[:current_version]/tours/:id' do
  	VCR.use_cassette('tours_view') do
  		require 'watir-webdriver'
	    browser = Watir::Browser.new :chrome
			browser.goto "http://localhost:3000/tours"
			# browser.text_field(id: 'tour').set("WebDriver rocks!")
			# browser.button(name: 'btnG').click
			puts browser.url
			browser.close
		end
  end
end