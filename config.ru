Dir.glob('./{models,helpers,services,controllers}/init.rb').each { |file| require file }

run ApplicationController