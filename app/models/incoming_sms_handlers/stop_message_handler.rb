module IncomingSmsHandlers
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
    end

  end
end
