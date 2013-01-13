require 'test_helper'

class IncomingSmsMessagesControllerTest < ActionController::TestCase

  def setup
    @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV['SIGNAL_RECEIVE_SMS_USERNAME'], ENV['SIGNAL_RECEIVE_SMS_PASSWORD'])
  end

  test "should deny access if credentials are incorrect" do
    @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('foo', 'bar')
    post :index, :mobile_phone => '9999999999', :message => 'foo bar'
    assert_response :unauthorized
  end

  test "should not freak out if we get a message for a mobile phone number we do not know about" do
    post :index, :mobile_phone => '9999999999', :message => 'foo bar'
    assert_response :success
  end

  test "should strip spaces from the incoming message" do
    user = users(:john)
    SmsMessagingService.any_instance.expects(:send_message).with(user.mobile_phone, OutgoingSmsMessages.signup_confirmation)

    assert_no_new_user do
      post :index, :mobile_phone => user.mobile_phone, :message => ' y '
    end
    assert_response :success
    assert user.reload.confirmed?
  end

end
