source 'http://rubygems.org'
ruby '2.2.3' #will cause exception if you are running a different version of ruby than what is specified here

gem 'sinatra'
gem 'thin'
gem 'json'
gem 'lonely_planet_tours'
gem 'activerecord'
gem 'sinatra-activerecord'
gem 'tux'
gem 'slim'
gem 'sinatra-flash'
gem 'httparty'
gem 'hirb'
gem 'puma'
gem 'virtus'
gem 'activemodel'
gem 'aws-sdk', '~>2'
gem 'dynamoid', '~>1'

group :test do
  gem 'minitest'
  gem 'rack'
  gem 'rack-test'
  gem 'vcr'
  gem 'webmock'
  #gem 'capybara-webkit', '~> 1.7', '>= 1.7.1'
  #gem 'minitest-capybara'
end

group :development, :test do
  gem 'sqlite3'
end

group :production do
  gem 'pg'
end
