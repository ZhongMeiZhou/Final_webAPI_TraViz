require 'virtus'
require 'json'

# Value object for tour details
class TourDetails
  include Virtus.model

  attribute :title, String
  attribute :price, Float
end


# Value object for tour listings
class TourListings
 include Virtus.model

 attribute :code, Integer
 attribute :id, Integer
 attribute :country, String
 attribute :tours, Array[TourDetails]

 def to_json
   to_hash.to_json
 end
end





tour = TourListings.new(
  :id     => 1,
  :country     => 'Belize',
  :tours => [
    { :title => 'hello', :price => 100 },
    { :title => 'nikki', :price => 400 } ]
  )
tour.code = 100
puts tour.to_json
#tour.tours.each do |t|
#puts t['title']
#end