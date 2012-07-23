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

  test "should ask the user for their location if only the keyword is sent" do
    SmsMessagingService.any_instance.expects(:send_message).with('3125551213', OutgoingSmsMessages.location_prompt)
    post :index, :mobile_phone => '3125551213', :message => ' aurora', :keyword => 'AURORA'
    assert_response :success
  end

  test "should be able to signup by texting AURORA with the zip code" do
    expects_valid_location("90210")
    SmsMessagingService.any_instance.expects(:send_message).with('3125551213', OutgoingSmsMessages.signup_confirmation)
    post :index, :mobile_phone => '3125551213', :message => ' aurora 90210 ', :keyword => 'AURORA'
    assert_response :success
  end

  test "should send an error if we cannot recognize the location" do
    expects_invalid_location("FOOBAZ")
    SmsMessagingService.any_instance.expects(:send_message).with('3125551213', OutgoingSmsMessages.bad_location_at_signup)
    post :index, :mobile_phone => '3125551213', :message => ' aurora foobaz ', :keyword => 'AURORA'
    assert_response :success
  end

end
