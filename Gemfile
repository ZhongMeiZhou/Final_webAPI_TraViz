source 'http://rubygems.org'
ruby '2.2.1'

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

group :test do
  gem 'minitest'
  gem 'rack'
  gem 'rack-test'
  gem 'vcr'
  gem 'webmock'
  gem 'watir'
  gem 'watir-webdriver', '~> 0.9.1'
end

group :development, :test do
  gem 'sqlite3'
end

group :production do
  gem 'pg'
end
