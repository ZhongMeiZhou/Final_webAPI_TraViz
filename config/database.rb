require 'dynamoid'
require 'aws-sdk'
require 'config_env'

ConfigEnv.path_to_config("#{__dir__}/../config/config_env.rb")

Aws.config.update({
  region: ENV['AWS_REGION'],
  credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY']),
  })

Dynamoid.configure do |config|
  config.adapter = 'aws_sdk_v2'
  config.namespace = 'zmztours_api'
  config.warn_on_scan = false
  config.read_capacity = 5
  config.write_capacity = 5
end
