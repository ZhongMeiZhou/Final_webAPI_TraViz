#require 'virtus'
#require 'active_model'
#require_relative '../forms/tourResult_form'

class CheckTours
  def call(country)
    return nil unless country

    tours = get_tours(country)
    return tours.to_json
  end

  private

  # Use the model tour to scrape the country's tours
  def get_tours(country)
      begin
        Tours.new(country)
      rescue StandardError => e
        # logger.info e.message
        halt 404, "#{e.message}"
      end
  end

end
