require 'shoryuken'
require 'config_env'
require 'sendgrid-ruby'
require 'pdfkit'
require 'json'

env_file = "#{__dir__}/../config/config_env.rb"
ConfigEnv.path_to_config(env_file) unless ENV['AWS_REGION']

class EmailWorker
  include Shoryuken::Worker
  shoryuken_options queue: 'zmz_email_queue', auto_delete: true

  def perform(sqs_msg, data)
    id = sqs_msg.message_id
    email = JSON.parse(data)["email"]
    url = JSON.parse(data)["url"]
    path = "exports/pdf/#{id}.pdf"

    client = SendGrid::Client.new(api_key: ENV['SG_API_KEY'])

    team = ['Bayardo','Cesar','Eduardo','Nicole']

    mail = SendGrid::Mail.new do |m|
      m.to = email
      m.from = "acctservices.emfg@gmail.com"
      m.from_name = "#{team[rand(0..3)]} at TraViz"
      m.subject = 'Your Tour Compare Report'
      m.text = "Here's the tour compare report you requested. Thank you for using TraViz."
    end
    # puts "create pdf of #{url}"
    create_pdf(url, path)
    # puts 'finish'
    mail.add_attachment(path, 'report.pdf')
    client.send(mail)
  end

  #This method created a pdf of the url 
  def create_pdf(url, file_name)
    kit = PDFKit.new(url);
    kit.to_file(file_name)
    puts kit
  end
end
