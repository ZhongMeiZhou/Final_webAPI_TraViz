Dir.glob('./{config,services,models,controllers}/init.rb').each { |file| require file }

run APITraViz
