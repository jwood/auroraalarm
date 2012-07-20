require 'test_helper'

class IncomingSmsMessagesControllerTest < ActionController::TestCase

  test "should not freak out if we get a message for a mobile phone number we do not know about" do
    post :index, :mobile_phone => '9999999999', :message => 'foo bar'
    assert_response :success
  end

  test "should be able to confirm an unconfirmed user" do
    user = users(:john)
    SmsMessagingService.any_instance.expects(:send_message).with(user.mobile_phone, OutgoingSmsMessages.signup_confirmation)

    post :index, :mobile_phone => user.mobile_phone, :message => ' y '
    assert_response :success
    assert user.reload.confirmed?
  end

end
