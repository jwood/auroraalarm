require 'test_helper'

class IncomingSmsMessagesControllerTest < ActionController::TestCase

  def setup
    ENV['TWILIO_AUTH_TOKEN'] = 'abc123'
  end

  test "should deny access if Twilio signature is incorrect" do
    params = {'From' => '9999999999', 'Body' => 'foo bar'}
    @request.env['HTTP_X_TWILIO_SIGNATURE'] = "BlahBlahBlah"
    post :index, params
    assert_response :unauthorized
  end

  test "should not freak out if we get a message for a mobile phone number we do not know about" do
    params = {'From' => '9999999999', 'Body' => 'foo bar'}
    set_twilio_signature(params)
    post :index, params
    assert_response :success
  end

  test "should strip spaces from the incoming message" do
    user = users(:john)
    Services::SmsMessagingService.any_instance.expects(:send_message).with(user.mobile_phone, OutgoingSmsMessages.signup_confirmation)

    params = {'From' => user.mobile_phone, 'Body' => ' y '}
    set_twilio_signature(params)
    assert_no_new_user do
      post :index, params
    end
    assert_response :success
    assert user.reload.confirmed?
  end

  private

  def set_twilio_signature(params)
    validator = Twilio::Util::RequestValidator.new(ENV['TWILIO_AUTH_TOKEN'])
    signature = validator.build_signature_for("http://test.host/incoming_sms_messages?#{params.sort.collect { |k,v| "#{k}=#{CGI.escape(v)}" }.join('&')}", params)
    @request.env['HTTP_X_TWILIO_SIGNATURE'] = signature
  end

end
