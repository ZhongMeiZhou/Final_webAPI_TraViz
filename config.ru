Dir.glob('./{config,models,services,controllers}/init.rb').each { |file| require file }

run APITraViz
