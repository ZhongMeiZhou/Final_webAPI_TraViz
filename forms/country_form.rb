require 'virtus'
require 'active_model'

class TourForm

include Virtus.model
include ActiveModel::Validations

attribute :country, String
attribute :country_two, String
attribute :tour_category, String

validates :country_one, presence: true

def error_fields
  errors.messages.keys.map(&:to_s).join(', ')
end

def to_json
  { country: :country, country_two: :country_two, tour_category: :tour_category }.to_json
end

end
