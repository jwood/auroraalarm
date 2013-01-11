Proby.api_key = Rails.env.test? ? 'test' : ENV['PROBY_API_KEY']
Proby.logger = Rails.logger

