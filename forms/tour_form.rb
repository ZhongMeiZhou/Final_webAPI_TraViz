require 'virtus'
require 'active_model'
require 'json'

class TourForm
  include Virtus.model
  include ActiveModel::Serializers::JSON
  include ActiveModel::Validations

  attribute :country, String

  validates :country, presence: true

  def error_fields
    errors.messages.keys.map(&:to_s).join(', ')
  end
end
