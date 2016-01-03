require 'hirb'
require 'sinatra/base'
require 'config_env'
require 'dalli'


class APITraViz < Sinatra::Base
  enable :sessions
  use Rack::MethodOverride

  configure do
    Hirb.enable
    set :session_secret, 'zmz!'
    set :api_ver, 'api/v2'
  end

  configure :development, :test do
    enable :logging
    set :api_server, 'http://localhost:3000'
    ConfigEnv.path_to_config("#{__dir__}/../config/config_env.rb")
  end

  configure :production do
    enable :logging
  end

  configure do
    set :traviz_cache, Dalli::Client.new((ENV["MEMCACHIER_SERVERS"] || "").split(","),
    {:username => ENV["MEMCACHIER_USERNAME"],
     :password => ENV["MEMCACHIER_PASSWORD"],
     :socket_timeout => 1.5,
     :socket_failure_delay => 0.2
    })
    set :traviz_cache_ttl, 1.day
  end
  
end
