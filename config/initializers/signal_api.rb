if Rails.env.test?
  ENV['SIGNAL_DELIVER_SMS_USERNAME'] = "username"
  ENV['SIGNAL_DELIVER_SMS_PASSWORD'] = "password"
end
