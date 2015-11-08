Dir.glob('./{models,helpers,controllers}/*.rb').each { |file| require file }

require 'rake/testtask'
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'


task :default => :spec

desc 'Run all tests'
Rake::TestTask.new(name = :spec) do |t|
  t.pattern = 'spec/*_spec.rb'
end
