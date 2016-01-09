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
    puts 'Starting to sent and email'
    puts data
    puts sqs_msg
    puts "Message id : #{data['id']}"    
    email = JSON.parse(data)["email"]
    url = JSON.parse(data)["url"]

    puts 'values'
    puts "email = #{email}"
    puts "url = #{url}"

    # get work

    client = SendGrid::Client.new(api_key: ENV['SG_API_KEY'])

    team = ['Bayardo','Cesar','Eduardo','Nicole']

    mail = SendGrid::Mail.new do |m|
      m.to = 'esalazar922@gmail.com'
      m.from = "acctservices.emfg@gmail.com"
      m.from_name = "#{team[rand(0..3)]} at TraViz"
      m.subject = 'Your Tour Compare Report'
      m.text = "Here's the tour compare report you requested. Thank you for using TraViz."
    end
    # puts "create pdf of #{url}"
    create_pdf url
    # puts 'finish'
    # #mail.add_attachment('/tmp/report.pdf', 'july_report.pdf')
    client.send(mail)
  end

  #This method created a pdf of the url 
  def create_pdf(url)
    kit = PDFKit.new(url);
    puts 'pdf created'
    puts kit.to_file('test.pdf')
  end
end
