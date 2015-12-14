#require_relative '../models/lonely_planet_tours'
require_relative '../models/tour'

module LP_APIHelpers
	VERSION = '2.0.0'

	#def get_tours(country)
  #    Tours.new(country)
  #  rescue StandardError => e
  #    logger.info e.message
  #    halt 404, "#{e.message}"
	#end

	# Use model tour.rb to find the object in DB
	def tour_finder (id)
			tour = Tour.find(id)
			country = tour.country
			tours = tour.tours
			logger.info({ id: tour.tour_id, country: country }.to_json)
			{ id: tour.tour_id, country: country, tours: tours}.to_json
		rescue
			return nil
	end

	# Use model tour.rb
	def get_country_id(country, only_tours)
		case check_db_tours(country, only_tours)
    	when 'Record exists'
      	return Tour.where({country: country}).first.tour_id
			when 'Record exists but tour details changed'
				tour = Tour.find_by_country(country)
				tour.tours = only_tours
				if tour.save
					#status 201
					return tour.tour_id
				else
					#halt 500, "Error updating tour details"
					raise Exception.new("Error updating tour details")
      	end
			when 'Country does not exist'
      	db_tour = Tour.new(country: country, tours: only_tours)
      	if db_tour.save
        	#status 201
					return db_tour.tour_id
				else
					#halt 500, "Error saving tours to the database"
					raise Exception.new("Error saving tours to the database")
      	end
			else
			end
	end

	# Use the model tour.rb
	def check_db_tours(country, tourslist)
		resultset = Tour.where({country: country}).first
    #if country tour details has not changed then show existing DB results
    if resultset && resultset.country == country && resultset.tours == tourslist
      'Record exists'
    else
    #if tours has changed but record exists just update the tour details
    	if resultset && resultset.tours != tourslist && resultset.country == country
      	'Record exists but tour details changed'
    	else
      	# if country not yet exists in the DB
      	'Country does not exist'
    	end
		end
	end

end
