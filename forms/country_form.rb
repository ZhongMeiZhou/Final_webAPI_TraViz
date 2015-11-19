require 'virtus'
require 'active_model'
require 'json'

class TourString < Virtus::Attribute
  def coerce(value)
    value.downcase
  end
end

class TourForm
  include Virtus.model
  include ActiveModel::Validations

  attribute :country, TourString
  attribute :country_two, TourString
  attribute :tour_category, TourString

  validates :country, presence: true

  def error_fields
    errors.messages.keys.map(&:to_s).join(', ')
  end

  def to_json
    { country: country, country_two: country_two, tour_category: tour_category }.to_json
  end

end
