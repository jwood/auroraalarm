class StopMessageHandler < MessageHandler

  def handle
    if stop_message?
      handle_stop_message
      return true
    end
    false
  end

  private

  def stop_message?
    @message.upcase =~ /STOP/
  end

  def handle_stop_message
    @user.destroy if @user
    @sms_messaging_service.send_message(@mobile_phone, OutgoingSmsMessages.stop)
  end

end
