require 'shoryuken'
require 'config_env'
require 'sendgrid-ruby'
require 'slim2pdf'
require 'json'
env_file = "#{__dir__}/../config/config_env.rb"
ConfigEnv.path_to_config(env_file) unless ENV['AWS_REGION']

class EmailWorker
  include Shoryuken::Worker
  shoryuken_options queue: 'zmz_email_queue', auto_delete: true

  def perform(sqs_msg, data)
    id = sqs_msg.message_id
    email = JSON.parse(data)["email"]
    result = JSON.parse(data)["result"]
    path = "exports/pdf/#{id}.pdf"

    client = SendGrid::Client.new(api_key: ENV['SG_API_KEY'])

    #team = ['Bayardo','Cesar','Eduardo','Nicole']

    mail = SendGrid::Mail.new do |m|
      m.to = email
      m.from = "acctservices.emfg@gmail.com"
      m.from_name = "Team TraViz"
      m.subject = 'Your Tour List Report'
      m.text = "Here's the tour compare report you requested. Thank you for using TraViz."
    end
    # puts "create pdf of #{url}"
    create_pdf(result, path)
    # puts 'finish'
    mail.add_attachment(path, 'report.pdf')
    client.send(mail)

    #remove file 
    File.delete(path)
  end

  #This method created a pdf of the url 
  def create_pdf(result, file_name)
    puts 'Creatig pdf'
    puts result['filtered_categories']
    writer = Slim2pdf::Writer.new
    writer.template = 'workers/template/tours.slim'
    writer.data = {results: result}
    writer.save_to_pdf(file_name) # saves rendered html as pdf file
  end




end
