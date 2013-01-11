module Stubs
  class StubbedSmsMessagingService
    attr_reader :sent_messages

    def initialize
      @sent_messages = []
    end

    def send_message(mobile_phone, message)
      @sent_messages << {:mobile_phone => mobile_phone, :message => message}
    end

  end
end
