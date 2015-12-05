require 'lonely_planet_tours'
require 'json'

class TourList

  def []= (title, trip)
    @tours ||= {}
    ##@tours['img'] = trip['img']
    @tours[title] = trip
    ##@tours['content'] = trip['content']
    ##@tours['price_currency'] = trip['price_currency']
    ##@tours['price'] = trip['price']
    ##@tours['category'] = trip['category']
  end

  def to_json
    @tours.map do |title, trip|
      { 'title' => title, 'price' => '$' + trip['price'], 'img' => trip['img'],
        'content' => trip['content'], 'price_currency' => trip['price_currency'],
        'category' => trip['category']}
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
      tour[trip['title']] = trip
    end
    tour.to_json
  end
end
