require 'lonely_planet_tours'
require 'json'

class TourList
  def []=(title, price)
    @tours ||= {}
    @tours[title] = price
  end

  def to_json
    @tours.map do |title, price|
      { 'title' => title, 'price' => '$'+price }
    end.to_json
  end
end


class Tours
  attr_reader :country, :tours

  def initialize(country)
    @country = country
    @tours = load_tours
  end

  def to_json
    { 'country' => @country, 'tours' => @tours }.to_json
  end


  private
  def load_tours
    tour = TourList.new
    country = LonelyPlanetScrape::LonelyPlanetTours.new(@country)
    JSON.parse(country.tours).each do |trip|
      tour[trip['title']] = trip['price']
    end
    tour.to_json
  end
end

#caused problem with tests
#test = Tours.new('taiwan')
#puts test.to_json