require 'shoryuken'
require 'config_env'
require 'sendgrid-ruby'
require 'pdfkit'

env_file = "#{__dir__}/../config/config_env.rb"
ConfigEnv.path_to_config(env_file) unless ENV['AWS_REGION']

class EmailWorker
  include Shoryuken::Worker
  shoryuken_options queue: 'zmz_email_queue', auto_delete: true

  def perform(sqs_msg, req)
    puts 'Starting to sent and email'
    email = req['email']
    url = req['url']
    client = SendGrid::Client.new(api_user: ENV['SG_UN'], api_key: ENV['SG_PW'])

    team = ['Bayardo','Cesar','Eduardo','Nicole']

    mail = SendGrid::Mail.new do |m|
      m.to = email
      m.from = "acctservices.emfg@gmail.com"
      m.from_name = "#{team[rand(0..3)]} at TraViz"
      m.subject = 'Your Tour Compare Report'
      m.text = "Here's the tour compare report you requested. Thank you for using TraViz."
    end
    puts "create pdf of #{url}"
    create_pdf url
    puts 'finish'
    #mail.add_attachment('/tmp/report.pdf', 'july_report.pdf')
    client.send(mail)
  end

  #This method created a pdf of the url 
  def create_pdf(url)
    kit = PDFKit.new(url);
    file = kit.to_file("../exports/pdf")
    puts file
  end
end
