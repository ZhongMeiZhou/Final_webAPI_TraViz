require_relative 'model/lonely_planet_tours'

module VisualizerAPIHelpers

	def get_tours(country)
      Tours.new(country)
    rescue
     halt 404
    end
end
