Dir.glob('./{config,models,services,helpers,controllers}/*.rb').each { |file| require file }

run APITraViz
