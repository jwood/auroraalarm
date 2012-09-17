class IncomingSmsHandler

  def initialize(mobile_phone, message, sms_messaging_service=nil)
    @mobile_phone = mobile_phone
    @message = message
    @sms_messaging_service = sms_messaging_service || SmsMessagingService.new
  end

  def process
    MessageHistory.create(:mobile_phone => @mobile_phone, :message => @message, :message_type => "MO")
    user = User.find_by_mobile_phone(@mobile_phone)

    handlers = [
      IncomingSmsHandlers::StopMessageHandler.new(@mobile_phone, @message, user, @sms_messaging_service),
      IncomingSmsHandlers::UnknownUserHandler.new(@mobile_phone, @message, user, @sms_messaging_service),
      IncomingSmsHandlers::AlertedUserHandler.new(@mobile_phone, @message, user, @sms_messaging_service),
      IncomingSmsHandlers::AlarmedUserHandler.new(@mobile_phone, @message, user, @sms_messaging_service),
      IncomingSmsHandlers::KnownUserHandler.new(@mobile_phone, @message, user, @sms_messaging_service)
    ]

    handled = false
    handlers.each do |handler|
      handled = handler.handle
      break if handled
    end

    if !handled
      @sms_messaging_service.send_message(@mobile_phone, OutgoingSmsMessages.unknown_request)
      Rails.logger.error "Unable to handle message \"#{@message}\" from mobile phone #{@mobile_phone}"
    end
  end

end
