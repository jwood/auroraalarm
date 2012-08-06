class IncomingMessageHandler

  def initialize(mobile_phone, message, keyword)
    @mobile_phone = mobile_phone
    @message = message
    @keyword = keyword
  end

  def process
    MessageHistory.create(:mobile_phone => @mobile_phone, :message => @message, :message_type => "MO")
    user = User.find_by_mobile_phone(@mobile_phone)

    handlers = [
      StopMessageHandler.new(@mobile_phone, @message, @keyword, user),
      UnknownUserHandler.new(@mobile_phone, @message, @keyword, user),
      AlertedUserHandler.new(@mobile_phone, @message, @keyword, user),
      AlarmedUserHandler.new(@mobile_phone, @message, @keyword, user),
      KnownUserHandler.new(@mobile_phone, @message, @keyword, user)
    ]

    handled = false
    handlers.each do |handler|
      handled = handler.handle
      break if handled
    end

    Rails.logger.error "Unable to handle message \"#{@message}\" from mobile phone #{@mobile_phone}" unless handled
  end

end
