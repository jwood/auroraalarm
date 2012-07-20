class SmsMessagingService

  def initialize
    username = ENV['SIGNAL_DELIVER_SMS_USERNAME']
    password = ENV['SIGNAL_DELIVER_SMS_PASSWORD']
    @deliver_sms = SignalApi::DeliverSms.new(username, password)
  end

  def send_message(mobile_phone, message)
    Rails.logger.info "Sending message to #{mobile_phone} : #{message}"
    if Rails.env.production?
      @deliver_sms.deliver(mobile_phone, message)
    end
  end

end
