require 'test_helper'

class IncomingSmsHandlerTest < ActiveSupport::TestCase

  test "should not freak out if we get a message for a mobile phone number we do not know about" do
    Services::SmsMessagingService.any_instance.expects(:send_message).with('9999999999', OutgoingSmsMessages.unknown_request)
    assert_no_new_user do
      IncomingSmsHandler.process('9999999999', 'foo bar')
    end
  end

  test "should be able to confirm an unconfirmed user" do
    user = users(:john)
    Services::SmsMessagingService.any_instance.expects(:send_message).with(user.mobile_phone, OutgoingSmsMessages.signup_confirmation)

    assert_no_new_user do
      IncomingSmsHandler.process(user.mobile_phone, 'y')
    end
    assert user.reload.confirmed?
  end

  test "should be able to decline an unconfirmed user" do
    user = users(:john)
    Services::SmsMessagingService.any_instance.expects(:send_message).with(user.mobile_phone, OutgoingSmsMessages.stop)

    assert_no_new_user do
      IncomingSmsHandler.process(user.mobile_phone, 'n')
    end
    assert !user.reload.confirmed?
  end

  test "should ask the user for their location if only the keyword is sent" do
    Services::SmsMessagingService.any_instance.expects(:send_message).with('3125551213', OutgoingSmsMessages.location_prompt)

    assert_no_new_user do
      IncomingSmsHandler.process('3125551213', 'aurora')
    end
  end

  test "should be able to signup by texting AURORA with the zip code" do
    expects_valid_location("90210")
    Services::SmsMessagingService.any_instance.expects(:send_message).with('3125551213', OutgoingSmsMessages.signup_confirmation)

    assert_new_user do
      IncomingSmsHandler.process('3125551213', 'aurora 90210')
    end
    assert User.find_by_mobile_phone('3125551213').confirmed?
  end

  test "should send an error if we cannot recognize the location" do
    Services::SmsMessagingService.any_instance.expects(:send_message).with('3125551213', OutgoingSmsMessages.bad_location_at_signup)

    assert_no_new_user do
      IncomingSmsHandler.process('3125551213', 'aurora foobaz')
    end
  end

  test "should send an error if the location provided is outside of the US" do
    expects_international_location("11300")
    Services::SmsMessagingService.any_instance.expects(:send_message).with('3125551213', OutgoingSmsMessages.international_location)

    assert_no_new_user do
      IncomingSmsHandler.process('3125551213', 'aurora 11300')
    end
  end

  test "shoud let the user know if they are already signed up" do
    user = users(:dan)
    Services::SmsMessagingService.any_instance.expects(:send_message).with(user.mobile_phone, OutgoingSmsMessages.already_signed_up)

    assert_no_new_user do
      IncomingSmsHandler.process(user.mobile_phone, 'aurora')
    end
  end

  test "shoud confirm the user if they are unconfirmed and text the keyword" do
    expects_valid_location("90210")
    user = users(:john)
    assert !user.confirmed?
    Services::SmsMessagingService.any_instance.expects(:send_message).with(user.mobile_phone, OutgoingSmsMessages.location_update("60477"))

    assert_no_new_user do
      IncomingSmsHandler.process(user.mobile_phone, 'aurora 90210')
    end
    assert user.reload.confirmed?
  end

  test "should unsubscribe confirmed user when they text STOP" do
    user = users(:dan)
    Services::SmsMessagingService.any_instance.expects(:send_message).never

    assert_user_deleted do
      IncomingSmsHandler.process(user.mobile_phone, 'stop')
    end
  end

  test "should unsubscribe unconfirmed user when they text STOP" do
    user = users(:john)
    Services::SmsMessagingService.any_instance.expects(:send_message).never

    assert_user_deleted do
      IncomingSmsHandler.process(user.mobile_phone, 'stop')
    end
  end

  test "should send unknown user the stop message when they text STOP" do
    Services::SmsMessagingService.any_instance.expects(:send_message).never

    assert_no_new_user do
      IncomingSmsHandler.process('3125551213', 'stop all')
    end
  end

  test "should update a users zip code if they are already subscribed and text AURORA followed by their zipcode" do
    user = users(:dan)
    assert_equal "55419", user.user_location.postal_code

    expects_valid_location("60477")
    Services::SmsMessagingService.any_instance.expects(:send_message).with(user.mobile_phone, OutgoingSmsMessages.location_update("60477"))

    assert_no_new_user do
      IncomingSmsHandler.process(user.mobile_phone, 'aurora 60477')
    end
    assert_equal "60477", user.user_location.reload.postal_code
  end

  test "should confirm a user and update their zip code if they are already subscribed and text AURORA followed by their zipcode" do
    user = users(:john)
    assert_equal "55419", user.user_location.postal_code
    assert !user.confirmed?

    expects_valid_location("60477")
    Services::SmsMessagingService.any_instance.expects(:send_message).with(user.mobile_phone, OutgoingSmsMessages.location_update("60477"))

    assert_no_new_user do
      IncomingSmsHandler.process(user.mobile_phone, 'aurora 60477')
    end
    assert_equal "60477", user.user_location.reload.postal_code
    assert user.reload.confirmed?
  end

  test "should return an error message if trying to update location with an invalid location value" do
    user = users(:dan)
    assert_equal "55419", user.user_location.postal_code

    expects_invalid_location("FOOBAR")
    Services::SmsMessagingService.any_instance.expects(:send_message).with(user.mobile_phone, OutgoingSmsMessages.bad_location_at_signup)

    assert_no_new_user do
      IncomingSmsHandler.process(user.mobile_phone, 'aurora foobar')
    end
    assert_equal "55419", user.user_location.reload.postal_code
  end

  test "should return an error message if trying to update location to an international location" do
    user = users(:dan)
    assert_equal "55419", user.user_location.postal_code

    expects_international_location("11300")
    Services::SmsMessagingService.any_instance.expects(:send_message).with(user.mobile_phone, OutgoingSmsMessages.international_location)

    assert_no_new_user do
      IncomingSmsHandler.process(user.mobile_phone, 'aurora 11300')
    end
    assert_equal "55419", user.user_location.reload.postal_code
  end

  test "should be able to approve an unapproved alert permission" do
    user = users(:bob)
    alert_permission = AlertPermission.create!(:user => user)

    Services::SmsMessagingService.any_instance.expects(:send_message).with(user.mobile_phone, OutgoingSmsMessages.approved_alert_permission)
    IncomingSmsHandler.process(user.mobile_phone, 'Y')
    assert_not_nil alert_permission.reload.approved_at
    assert_not_nil alert_permission.reload.expires_at
  end

  test "should be able to decline an unapproved alert permission" do
    user = users(:bob)
    alert_permission = AlertPermission.create!(:user => user)

    Services::SmsMessagingService.any_instance.expects(:send_message).with(user.mobile_phone, OutgoingSmsMessages.declined_alert_permission)
    IncomingSmsHandler.process(user.mobile_phone, 'N')
    assert_nil AlertPermission.find_by_id(alert_permission)
  end

  test "should record all incoming messages in the message history table" do
    expects_valid_location("90210")
    Services::SmsMessagingService.any_instance.expects(:send_message).with('3125551213', OutgoingSmsMessages.signup_confirmation)
    assert_difference 'MessageHistory.count', 1 do
      IncomingSmsHandler.process('3125551213', 'aurora 90210')
    end

    message_history = MessageHistory.last
    assert_equal '3125551213', message_history.mobile_phone
    assert_equal 'aurora 90210', message_history.message
    assert_equal 'MO', message_history.message_type
  end

  test "should be able to handle the acknowledgement of an aurora alert" do
    user = users(:bob)
    AuroraAlert.create!(:user => user)
    Services::SmsMessagingService.any_instance.expects(:send_message).with(user.mobile_phone, OutgoingSmsMessages.acknowledge_alert)
    IncomingSmsHandler.process(user.mobile_phone, '0')
    user.reload
    assert_not_nil user.aurora_alert.confirmed_at
    assert_nil user.aurora_alert.send_reminder_at
  end

  test "should be able handle users asking to be reminded of the aurora in 1 hour" do
    begin
      Timecop.freeze(Time.now)
      user = users(:bob)
      AuroraAlert.create!(:user => user)
      Services::SmsMessagingService.any_instance.expects(:send_message).with(user.mobile_phone, OutgoingSmsMessages.remind_at("1 hour"))
      IncomingSmsHandler.process(user.mobile_phone, '1')
      user.reload
      assert_not_nil user.aurora_alert.confirmed_at
      assert_time_roughly 1.hour.from_now, user.aurora_alert.send_reminder_at
    ensure
      Timecop.return
    end
  end

  test "should be able handle users asking to be reminded of the aurora in 2 hours" do
    begin
      Timecop.freeze(Time.now)
      user = users(:bob)
      AuroraAlert.create!(:user => user)
      Services::SmsMessagingService.any_instance.expects(:send_message).with(user.mobile_phone, OutgoingSmsMessages.remind_at("2 hours"))
      IncomingSmsHandler.process(user.mobile_phone, '2)')
      user.reload
      assert_not_nil user.aurora_alert.confirmed_at
      assert_time_roughly 2.hours.from_now, user.aurora_alert.send_reminder_at
    ensure
      Timecop.return
    end
  end

  test "should be able handle users asking that no more auora alarms be sent that night" do
    user = users(:bob)
    AuroraAlert.create!(:user => user)
    Services::SmsMessagingService.any_instance.expects(:send_message).with(user.mobile_phone, OutgoingSmsMessages.no_more_messages_tonight)
    IncomingSmsHandler.process(user.mobile_phone, '3')
    user.reload
    assert_not_nil user.aurora_alert.confirmed_at
    assert_nil user.aurora_alert.send_reminder_at
  end

end
