module Services
  class SmsMessagingService

    def initialize(options={})
      account_sid = ENV['TWILIO_ACCOUNT_SID']
      auth_token = ENV['TWILIO_AUTH_TOKEN']
      @client = Twilio::REST::Client.new(account_sid, auth_token)
      @force_send = options[:force_send]
    end

    def send_message(mobile_phone, message)
      Rails.logger.info "Sending message to #{mobile_phone} : #{message}"
      if Rails.env.production? || @force_send
        MessageHistory.create(:mobile_phone => mobile_phone, :message => message, :message_type => "MT")
        @client.account.sms.messages.create(:from => '+13123865114', :to => mobile_phone, :body => message)
      end
    end

  end
end
