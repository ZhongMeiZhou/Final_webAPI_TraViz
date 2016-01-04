require 'shoryuken'
require 'config_env'
require 'sendgrid-ruby'

env_file = "#{__dir__}/../config/config_env.rb"
ConfigEnv.path_to_config(env_file)

class EmailWorker
  include Shoryuken::Worker
  shoryuken_options queue: 'zmz_email_queue', auto_delete: true

  def perform(sqs_msg, email)
    client = SendGrid::Client.new(api_user: ENV['SG_UN'], api_key: ENV['SG_PW'])

    mail = SendGrid::Mail.new do |m|
      m.to = email
      m.from = "acctservices.emfg@gmail.com"
      m.from_name = 'Travis Johnson, Travel Agent'
      m.subject = 'Test Subject'
      m.text = 'Content'
    end
    client.send(mail)
  end
end
