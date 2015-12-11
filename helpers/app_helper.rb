#require_relative '../models/lonely_planet_tours'

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
		begin
			tour = Tour.find(id)
			country = tour.country
			tours = tour.tours
			logger.info({ id: tour.id, country: country }.to_json)
			{ id: tour.id, country: country, tours: tours}.to_json
		rescue
			halt 400
		end
	end

	def get_country_id(country, only_tours)
		resultset = Tour.where(["country = ?", country]).first
		case check_db_tours(resultset, country, only_tours)
    	when 'Record exists'
      	return resultset.id
			when 'Record exists but tour details changed'
				tour = Tour.find_by(country: country)
				tour.tours = only_tours
				if tour.save
					status 201
					return tour.id
				else
					halt 500, "Error updating tour details"
      	end
			when 'Country does not exist'
      	db_tour = Tour.new(country: country, tours: only_tours)
      	if db_tour.save
        	status 201
					return db_tour.id
				else
					halt 500, "Error saving tours to the database"
      	end
			end
		end
	end

	def check_db_tours(resultset, country, tourslist)
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
