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
  gem 'capybara-webkit', '~> 1.7', '>= 1.7.1'
  gem 'minitest-capybara'
end

group :development, :test do
  gem 'sqlite3'

end

group :production do
  gem 'pg'
end
