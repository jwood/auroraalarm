source 'https://rubygems.org'

gem 'rails', '3.2.8'
gem 'jquery-rails', '2.0.2'

gem 'pg', '0.14.0'

gem 'foreigner', '1.2.0'
gem 'geokit', '1.6.5'
gem 'dalli', '2.1.0'
gem 'signal_api', :git => 'git://github.com/signal/signal-ruby.git'
gem 'proby', '2.2.0'
gem 'exception_notification', '2.6.1', :require => 'exception_notifier'
gem 'moonphase', :git => 'git://github.com/chaserx/moonphase.git'
gem 'RubySunrise', '0.3', :require => 'solareventcalculator'
gem 'nokogiri', '1.5.5'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'therubyracer', :platforms => :ruby
  gem 'uglifier', '>= 1.0.3'
end

group :test do
  gem 'shoulda', '3.1.0'
  gem 'fakeweb', '1.3.0'
  gem 'mocha', '0.12.0'
  gem 'simplecov', '0.6.4', :require => false
  gem 'timecop', '0.4.4'
end

group :production do
  gem 'newrelic_rpm', '3.4.0.1'
end
