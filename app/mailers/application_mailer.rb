class ApplicationMailer < ActionMailer::Base
  default from: "noreply@#{ENV.fetch('MAILGUN_DOMAIN', 'example.com')}"
  layout 'mailer'
end
