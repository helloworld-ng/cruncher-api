# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

# Sendgrid
ActionMailer::Base.smtp_settings = {
  :address        => 'smtp.sendgrid.net',
  :port           => '587',
  :authentication => :plain,
  :user_name      => ENV['app36268553@heroku.com'],
  :password       => ENV['g1a8zdfy'],
  :domain         => 'heroku.com',
  :enable_starttls_auto => true
}