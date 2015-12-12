Dir.glob('./{config,models,services,controllers}/*.rb').each { |file| require file }

run APITraViz
