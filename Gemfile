source 'https://rubygems.org'
ruby '2.0.0'

gem 'rails'
gem 'jquery-rails', '2.0.3'

gem 'unicorn'
gem 'foreman'

gem 'pg'

gem 'foreigner'
gem 'geokit'
gem 'dalli'
gem 'signal_api', git: 'git://github.com/signal/signal-ruby.git'
gem 'proby'
gem 'exception_notification'
gem 'moonphase', git: 'git://github.com/jwood/moonphase.git'
gem 'RubySunrise', require: 'solareventcalculator'
gem 'nokogiri'

gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'

group :development do
  gem 'thin'
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
  gem 'rails_12factor'
  gem 'memcachier'
end
