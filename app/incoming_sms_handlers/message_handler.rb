class MessageHandler

  def initialize(mobile_phone, message, user, sms_messaging_service)
    @mobile_phone = mobile_phone
    @message = message
    @user = user
    @sms_messaging_service = sms_messaging_service
  end

  def handle
    raise "Should be implemented by subclass"
  end

  protected

  def opt_in_message_regexp
    @opt_in_message_regexp ||= Regexp.new("^AURORA\s+(.*)$", Regexp::IGNORECASE)
  end

  def opt_in_via_sms?
    @message.upcase =~ opt_in_message_regexp
  end

  def positive_response?
    ["Y", "YES", "SURE", "OK", "YEP", "CONFIRM"].include?(@message.upcase)
  end

  def negative_response?
    ["N", "NO", "NOPE"].include?(@message.upcase)
  end

end
