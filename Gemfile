source 'https://rubygems.org'

gem 'rails', '3.2.13'
gem 'jquery-rails'

gem 'unicorn'
gem 'foreman'

gem 'pg'

gem 'strong_parameters'
gem 'foreigner'
gem 'geokit'
gem 'dalli'
gem 'signal_api', git: 'git://github.com/signal/signal-ruby.git'
gem 'proby'
gem 'exception_notification', require: 'exception_notifier'
gem 'moonphase', git: 'git://github.com/jwood/moonphase.git'
gem 'RubySunrise', require: 'solareventcalculator'
gem 'nokogiri'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

group :test do
  gem 'fakeweb'
  gem 'mocha', require: false
  gem 'simplecov'
  gem 'timecop'
  gem 'coveralls', require: false
end

group :production do
  gem 'newrelic_rpm'
end
