if Rails.env.test?
  ENV['SIGNAL_DELIVER_SMS_USERNAME'] = "username"
  ENV['SIGNAL_DELIVER_SMS_PASSWORD'] = "password"
  ENV['SIGNAL_RECEIVE_SMS_USERNAME'] = "username"
  ENV['SIGNAL_RECEIVE_SMS_PASSWORD'] = "password"
end

SignalApi.api_key = ENV['SIGNAL_API_KEY']
SignalApi.logger = Rails.logger
