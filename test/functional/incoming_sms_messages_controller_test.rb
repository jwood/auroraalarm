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

  test "should be able to confirm an unconfirmed user" do
    user = users(:john)
    SmsMessagingService.any_instance.expects(:send_message).with(user.mobile_phone, OutgoingSmsMessages.signup_confirmation)

    assert_no_new_user do
      post :index, :mobile_phone => user.mobile_phone, :message => ' y '
    end
    assert_response :success
    assert user.reload.confirmed?
  end

  test "should be able to signup by texting AURORA with the zip code" do
    expects_valid_location("90210")
    SmsMessagingService.any_instance.expects(:send_message).with('3125551213', OutgoingSmsMessages.signup_confirmation)

    assert_new_user do
      post :index, :mobile_phone => '3125551213', :message => ' aurora 90210 ', :keyword => 'AURORA'
    end
    assert_response :success
  end

  test "should send an error if we cannot recognize the location" do
    expects_invalid_location("FOOBAZ")
    SmsMessagingService.any_instance.expects(:send_message).with('3125551213', OutgoingSmsMessages.bad_location_at_signup)

    assert_no_new_user do
      post :index, :mobile_phone => '3125551213', :message => ' aurora foobaz ', :keyword => 'AURORA'
    end
    assert_response :success
  end

  test "shoud let the user know if they are already signed up" do
    user = users(:dan)
    SmsMessagingService.any_instance.expects(:send_message).with(user.mobile_phone, OutgoingSmsMessages.already_signed_up)

    assert_no_new_user do
      post :index, :mobile_phone => user.mobile_phone, :message => ' aurora', :keyword => 'AURORA'
    end
    assert_response :success
  end

  test "should unsubscribe confirmed user when they text STOP" do
    user = users(:dan)
    SmsMessagingService.any_instance.expects(:send_message).with(user.mobile_phone, OutgoingSmsMessages.stop)

    assert_user_deleted do
      post :index, :mobile_phone => user.mobile_phone, :message => ' stop', :keyword => ''
    end
    assert_response :success
  end

  test "should unsubscribe unconfirmed user when they text STOP" do
    user = users(:john)
    SmsMessagingService.any_instance.expects(:send_message).with(user.mobile_phone, OutgoingSmsMessages.stop)

    assert_user_deleted do
      post :index, :mobile_phone => user.mobile_phone, :message => ' stop', :keyword => ''
    end
    assert_response :success
  end

  test "should send unknown user the stop message when they text STOP" do
    SmsMessagingService.any_instance.expects(:send_message).with('3125551213', OutgoingSmsMessages.stop)

    assert_no_new_user do
      post :index, :mobile_phone => '3125551213', :message => ' stop all', :keyword => ''
    end
    assert_response :success
  end

  test "should update a users zip code if they are already subscribed and text AURORA followed by their zipcode" do
    user = users(:dan)
    assert_equal "55419", user.user_location.postal_code

    expects_valid_location("60477")
    SmsMessagingService.any_instance.expects(:send_message).with(user.mobile_phone, OutgoingSmsMessages.location_update("60477"))

    assert_no_new_user do
      post :index, :mobile_phone => user.mobile_phone, :message => ' aurora 60477 ', :keyword => 'AURORA'
    end
    assert_response :success
    assert_equal "60477", user.user_location.reload.postal_code
  end

  test "should return an error message if trying to update location with an invalid location value" do
    user = users(:dan)
    assert_equal "55419", user.user_location.postal_code

    expects_invalid_location("FOOBAR")
    SmsMessagingService.any_instance.expects(:send_message).with(user.mobile_phone, OutgoingSmsMessages.bad_location_at_signup)

    assert_no_new_user do
      post :index, :mobile_phone => user.mobile_phone, :message => ' aurora foobar ', :keyword => 'AURORA'
    end
    assert_response :success
    assert_equal "55419", user.user_location.reload.postal_code
  end

  private

  def assert_new_user
    assert_difference 'User.count', 1 do
      assert_difference 'UserLocation.count', 1 do
        yield
      end
    end
  end

  def assert_no_new_user
    assert_no_difference 'User.count' do
      assert_no_difference 'UserLocation.count' do
        yield
      end
    end
  end

  def assert_user_deleted
    assert_difference 'User.count', -1 do
      assert_difference 'UserLocation.count', -1 do
        yield
      end
    end
  end

end
