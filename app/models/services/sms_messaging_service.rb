module Services
  class SmsMessagingService

    def initialize(options={})
      username = ENV['SIGNAL_DELIVER_SMS_USERNAME']
      password = ENV['SIGNAL_DELIVER_SMS_PASSWORD']
      @deliver_sms = SignalApi::DeliverSms.new(username, password)
      @force_send = options[:force_send]
    end

    def send_message(mobile_phone, message)
      Rails.logger.info "Sending message to #{mobile_phone} : #{message}"
      if Rails.env.production? || @force_send
        MessageHistory.create(:mobile_phone => mobile_phone, :message => message, :message_type => "MT")
        @deliver_sms.deliver(mobile_phone, message)
      end
    end

  end
end
