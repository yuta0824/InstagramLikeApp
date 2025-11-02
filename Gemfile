source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.2.3"
# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]
# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false
# Use Tailwind CSS for styling [https://tailwindcss.com/docs/guides/ruby-on-rails]
gem 'tailwindcss-rails', '~> 4.3'
# Use Devise for authentication [https://github.com/heartcombo/devise]
gem 'devise'
# Use Haml for templating [https://haml.info]
gem 'hamlit'
# AWS SDK for Ruby - S3 [https://github.com/aws/aws-sdk-ruby]
gem 'aws-sdk-s3', require: false
# Serializer [https://github.com/rails-api/active_model_serializers]
gem 'active_model_serializers'
# rswag [https://github.com/rswag/rswag]
gem 'rswag'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[ mri windows ], require: 'debug/prelude'
  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem 'brakeman', require: false
  # Use RuboCop for code linting [https://rubocop.org/]
  gem 'rubocop-rails'
  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem 'rubocop-rails-omakase', require: false
  # Use Pry for debugging [https://github.com/pry/pry]
  gem 'pry-byebug'
  # Use .env files [https://github.com/bkeepers/dotenv]
  gem 'dotenv-rails'
  # Use RSpec for testing [https://github.com/rspec/rspec-rails]
  gem 'rspec-rails'
  # Generation of dummy data [https://github.com/faker-ruby/faker]
  gem 'faker'
  # Test fixtures replacement with factories [https://github.com/thoughtbot/factory_bot_rails]
  gem 'factory_bot_rails'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'
  # Convert ERB templates to HAML [https://github.com/dhl/erb2haml]
  gem 'erb2haml'
  # Annotate models and routes with schema information [https://github.com/ctran/annotate_models]
  gem 'annotate'
  # HAML files clean and readable [https://github.com/sds/haml-lint]
  gem 'haml_lint', require: false
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end
