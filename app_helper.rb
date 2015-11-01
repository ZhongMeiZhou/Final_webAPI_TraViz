require_relative 'model/lonely_planet_tours'

module VisualizerAPIHelpers
	VERSION = '1.0.1'

	def get_tours(country)
      Tours.new(country)
    rescue
     halt 404
    end
end
