Dir.glob('./{model, helper, controller}/*.rb').each { |file| require file}

run ApplicationController
