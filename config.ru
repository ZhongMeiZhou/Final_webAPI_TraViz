Dir.glob('./{controllers, helpers, models}/*.rb').each { |file| require file }

run ApplicationController
