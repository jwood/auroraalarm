require 'test_helper'

class SmsMessagingServiceTest < ActiveSupport::TestCase

  def setup
    @service = SmsMessagingService.new(:force_send => true)
  end

  test "should be able to send a SMS message" do
    SignalApi::DeliverSms.any_instance.expects(:deliver).with("3125551212", "Some message")
    assert_difference 'MessageHistory.count', 1 do
      @service.send_message("3125551212", "Some message")
    end

    message_history = MessageHistory.last
    assert_equal '3125551212', message_history.mobile_phone
    assert_equal 'Some message', message_history.message
    assert_equal 'MT', message_history.message_type
  end

end
