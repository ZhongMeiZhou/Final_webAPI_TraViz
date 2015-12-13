require 'virtus'
require 'active_model'
require 'json'

#not needed since web app being removed
class TourString < Virtus::Attribute
  def coerce(value)
    value.downcase
  end
end

class TourCompareForm
  include Virtus.model
  include ActiveModel::Validations
  include ActiveModel::Serializers::JSON

  attribute :country, TourString
  attribute :country_two, TourString
  attribute :tour_category, TourString

  validates :country, presence: true
  validates :country_two, presence: true
  validates :tour_category, presence: true

  def error_fields
    errors.messages.keys.map(&:to_s).join(', ')
  end

end
