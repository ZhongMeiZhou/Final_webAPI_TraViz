Dir.glob('./{config,models,services,helpers,controllers}/init.rb').each { |file| require file }

run APITraViz
