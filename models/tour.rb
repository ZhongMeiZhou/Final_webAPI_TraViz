require 'dynamoid'

class Tour
  include Dynamoid::Document

  table :name => :tours, :key => :tour_id, :read_capacity => 5, :write_capacity => 5

  field :country, :string
  field :tours, :string

  def self.destroy(id)
    find(id).destroy
  end

  def self.delete_all
    all.each(&:delete)
  end
end
