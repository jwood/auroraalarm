if Rails.env.test?
  Proby.api_key = 'test'
else
  Proby.api_key = ENV['PROBY_API_KEY']
end

Proby.logger = Rails.logger

