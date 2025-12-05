class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('MAIL_FROM_ADDRESS', 'from@example.com')
  layout 'mailer'
end
