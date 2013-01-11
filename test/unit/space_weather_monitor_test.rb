require 'test_helper'

class SpaceWeatherMonitorTest < ActiveSupport::TestCase

  def setup
    @monitor = SpaceWeatherMonitor.new(:moon => Stubs::StubbedMoon.new(:new))
    @yesterday = (DateTime.now.utc - 1.day).to_date
    @today = DateTime.now.utc.to_date
  end

  test "should alert users if no solar event occurred yesterday, but one occurred today" do
    Services::SmsMessagingService.any_instance.expects(:send_message).times(2).with() { |mobile_phone, message| message == OutgoingSmsMessages.storm_prompt(GeomagneticStorm.build("G2")) }
    Services::SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(@yesterday).returns(nil)
    Services::SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(@today).returns(solar_event("G2", DateTime.now.utc))
    assert_difference 'SolarEvent.count', 1 do
      assert_difference 'AlertPermission.count', 2 do
        @monitor.alert_users_of_solar_event
      end
    end
  end

  test "should alert users if a new event occurred yesterday, and no event occurred today" do
    Services::SmsMessagingService.any_instance.expects(:send_message).times(2).with() { |mobile_phone, message| message == OutgoingSmsMessages.storm_prompt(GeomagneticStorm.build("G2")) }
    Services::SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(@yesterday).returns(solar_event("G2", DateTime.now.utc))
    Services::SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(@today).returns(nil)
    assert_difference 'SolarEvent.count', 1 do
      assert_difference 'AlertPermission.count', 2 do
        @monitor.alert_users_of_solar_event
      end
    end
  end

  test "should alert users if a stronger solar event occurred yesterday, after the alert went out, but nothing occurred today" do
    Services::SmsMessagingService.any_instance.expects(:send_message).times(2).with() { |mobile_phone, message| message == OutgoingSmsMessages.storm_prompt(GeomagneticStorm.build("G2")) }
    create_yesterdays_previously_recorded_event("G1")
    Services::SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(@yesterday).returns(solar_event("G2", DateTime.now.utc - 1.day))
    Services::SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(@today).returns()
    assert_no_difference 'SolarEvent.count' do
      assert_difference 'AlertPermission.count', 2 do
        @monitor.alert_users_of_solar_event
      end
    end
    assert_equal "G2", SolarEvent.occurred_on((DateTime.now.utc - 1.day).to_date).expected_storm_strength
  end

  test "should alert users of the strongest event if events occurred yesterday and today" do
    Services::SmsMessagingService.any_instance.expects(:send_message).times(3).with() { |mobile_phone, message| message == OutgoingSmsMessages.storm_prompt(GeomagneticStorm.build("G4")) }
    create_yesterdays_previously_recorded_event("G3")
    Services::SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(@yesterday).returns(solar_event("G4", DateTime.now.utc - 1.day))
    Services::SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(@today).returns(solar_event("G2", DateTime.now.utc))
    assert_difference 'SolarEvent.count', 1 do
      assert_difference 'AlertPermission.count', 3 do
        @monitor.alert_users_of_solar_event
      end
    end
  end

  test "should create two new solar events if 2 days of solar activity occur since the last time we checked" do
    Services::SmsMessagingService.any_instance.expects(:send_message).times(2).with() { |mobile_phone, message| message == OutgoingSmsMessages.storm_prompt(GeomagneticStorm.build("G3")) }
    Services::SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(@yesterday).returns(solar_event("G3", DateTime.now.utc - 1.day))
    Services::SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(@today).returns(solar_event("G2", DateTime.now.utc))
    assert_difference 'SolarEvent.count', 2 do
      assert_difference 'AlertPermission.count', 2 do
        @monitor.alert_users_of_solar_event
      end
    end
  end

  test "should not alert users if no solar events occurred yesterday or today" do
    Services::SmsMessagingService.any_instance.expects(:send_message).never
    Services::SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(@yesterday).returns(nil)
    Services::SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(@today).returns(nil)
    assert_no_difference 'SolarEvent.count' do
      assert_no_difference 'AlertPermission.count' do
        @monitor.alert_users_of_solar_event
      end
    end
  end

  test "should not alert users if no solar events occurred after we sent the alert yesterday" do
    Services::SmsMessagingService.any_instance.expects(:send_message).never
    create_yesterdays_previously_recorded_event("G2")
    Services::SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(@yesterday).returns(solar_event("G2", DateTime.now.utc - 1.day))
    Services::SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(@today).returns(nil)
    assert_no_difference 'SolarEvent.count' do
      assert_no_difference 'AlertPermission.count' do
        @monitor.alert_users_of_solar_event
      end
    end
  end

  test "should not alert users if a weaker solar event occurred yesterday after the alert went out, and nothing occurred today" do
    Services::SmsMessagingService.any_instance.expects(:send_message).never
    create_yesterdays_previously_recorded_event("G2")
    Services::SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(@yesterday).returns(solar_event("G1", DateTime.now.utc - 1.day))
    Services::SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(@today).returns(nil)
    assert_no_difference 'SolarEvent.count' do
      assert_no_difference 'AlertPermission.count' do
        @monitor.alert_users_of_solar_event
      end
    end
  end

  test "should replace unapproved alert permissions with new ones if old ones exist" do
    alert_permission = AlertPermission.create!(:user => users(:dan))
    Services::SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(@yesterday).returns(nil)
    Services::SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(@today).returns(solar_event("G3", DateTime.now.utc))
    assert_difference 'AlertPermission.count', 1 do
      @monitor.alert_users_of_solar_event
    end
    assert_nil AlertPermission.find_by_id(alert_permission)
    assert_not_nil AlertPermission.for_user(users(:dan)).first
  end

  test "should create a new unapproved alert permissions if an existing approved one already exists" do
    alert_permission = AlertPermission.create!(:user => users(:dan), :approved_at => Time.now)
    Services::SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(@yesterday).returns(nil)
    Services::SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(@today).returns(solar_event("G3", DateTime.now.utc))
    assert_difference 'AlertPermission.count', 2 do
      @monitor.alert_users_of_solar_event
    end
    assert_equal 2, AlertPermission.for_user(users(:dan)).count
  end

  test "should destroy all expired alert permissions before running the process to create new ones" do
    AlertPermission.create!(:user => users(:dan), :approved_at => Time.now, :expires_at => 1.minute.ago)
    AlertPermission.create!(:user => users(:john), :approved_at => Time.now, :expires_at => 1.minute.ago)
    AlertPermission.create!(:user => users(:bob), :approved_at => Time.now, :expires_at => 10.minutes.from_now)

    Services::SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(@yesterday).returns(nil)
    Services::SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(@today).returns(nil)
    assert_difference 'AlertPermission.count', -2 do
      @monitor.alert_users_of_solar_event
    end
  end

  test "should not send any alerts if the moon will not be dark over the next 3 days" do
    monitor = SpaceWeatherMonitor.new(:moon => Stubs::StubbedMoon.new(:full))
    Services::SmsMessagingService.any_instance.expects(:send_message).never
    Services::SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(@yesterday).returns(nil)
    Services::SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(@today).returns(solar_event("G2", DateTime.now.utc))
    assert_difference 'SolarEvent.count', 1 do
      assert_no_difference 'AlertPermission.count' do
        monitor.alert_users_of_solar_event
      end
    end
  end

  test "should alert users if they should be able to see the aurora at their geomagnetic latitude" do
    Services::SmsMessagingService.any_instance.expects(:send_message).times(3).with() { |mobile_phone, message| message == OutgoingSmsMessages.storm_prompt(GeomagneticStorm.build("G5")) }
    Services::SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(@yesterday).returns(solar_event("G5", DateTime.now.utc))
    Services::SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(@today).returns(nil)
    assert_difference 'SolarEvent.count', 1 do
      assert_difference 'AlertPermission.count', 3 do
        @monitor.alert_users_of_solar_event
      end
    end
  end

  private

  def create_yesterdays_previously_recorded_event(strength)
    SolarEvent.create!(
      :message_code => "WATA050",
      :serial_number => new_serial_number,
      :issue_time => DateTime.now.utc - 1.day,
      :expected_storm_strength => strength)
  end

end
