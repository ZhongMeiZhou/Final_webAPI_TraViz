Dir.glob('./{controllers,models,helpers}/*.rb').each { |file| require file }

#https://github.com/janko-m/sinatra-activerecord/issues/36
require 'rake/testtask'
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'


task :default => :spec

desc 'Run all tests'
Rake::TestTask.new(name = :spec) do |t|
  t.pattern = 'spec/*_spec.rb'
end
