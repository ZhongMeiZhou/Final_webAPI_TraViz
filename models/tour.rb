require 'dynamoid'

class Tour
  include Dynamoid::Document
  field :country, :string
  field :tours, :string

  def self.destroy(id)
    find(id).destroy
  end

  def self.delete_all
    all.each(&:delete)
  end
end
