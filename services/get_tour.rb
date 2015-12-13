require_relative '../models/init'

module GetTours

	def get_tours_by_country(country)
      Tours.new(country)
    rescue StandardError => e
      logger.info e.message
      halt 404, "#{e.message}"
    end
end
