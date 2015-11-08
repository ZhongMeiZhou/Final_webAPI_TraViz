require_relative '../models/lonely_planet_tours'

module VisualizerAPIHelpers
	VERSION = '1.0.1'

	def get_tours(country)
      Tours.new(country)
    rescue StandardError => e
      logger.info e.message
      halt 404, "#{e.message}"
    end
end
