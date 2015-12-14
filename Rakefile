Dir.glob('./{config,models,services,helpers,controllers}/init.rb').each { |file| require file }

require 'rake/testtask'
#require 'sinatra/activerecord'
#require 'sinatra/activerecord/rake'

task :default => :spec

desc 'Run all tests'
Rake::TestTask.new(name = :spec) do |t|
   t.pattern = 'spec/app_spec.rb' #only need to test API behaviour
end

namespace :db do
  require_relative 'config/init'
  require_relative 'models/tour'

  desc 'Create tutorial table'
  task :migrate do
    begin
      Tour.create_table
      puts "Table created!"
    rescue Aws::DynamoDB::Errors::ResourceInUseException => e
      puts "Table already exists"
    end
  end
end
