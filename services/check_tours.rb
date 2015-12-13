module CheckTours

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
