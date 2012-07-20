require 'test_helper'

class SmsMessagingServiceTest < ActiveSupport::TestCase

  def setup
    @service = SmsMessagingService.new
  end

  test "should be able to send a SMS message" do
    begin
      Rails.env = 'production'
      SignalApi::DeliverSms.any_instance.expects(:deliver).with("3125551212", "Some message")
      @service.send_message("3125551212", "Some message")
    ensure
      Rails.env = 'test'
    end
  end

end
