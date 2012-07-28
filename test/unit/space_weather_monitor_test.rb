require 'test_helper'

class SpaceWeatherMonitorTest < ActiveSupport::TestCase

  def setup
    @monitor = SpaceWeatherMonitor.new
  end

  test "should alert users if no solar event occurred yesterday, but one occurred today" do
    SmsMessagingService.any_instance.expects(:send_message).times(2).with() { |mobile_phone, message| message == OutgoingSmsMessages.storm_prompt(GeomagneticStorm.new("G2")) }
    SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(Date.yesterday).returns(nil)
    SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(Date.today).returns(solar_event("G2", DateTime.now.utc))
    assert_difference 'SolarEvent.count', 1 do
      assert_difference 'AlertPermission.count', 2 do
        @monitor.alert_users_of_solar_event
      end
    end
  end

  test "should alert users if a stronger solar event occurred yesterday, after the alert went out, but nothing occurred today" do
    SmsMessagingService.any_instance.expects(:send_message).times(2).with() { |mobile_phone, message| message == OutgoingSmsMessages.storm_prompt(GeomagneticStorm.new("G2")) }
    create_yesterdays_previously_recorded_event("G1")
    SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(Date.yesterday).returns(solar_event("G2", DateTime.now.utc - 1.day))
    SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(Date.today).returns()
    assert_no_difference 'SolarEvent.count' do
      assert_difference 'AlertPermission.count', 2 do
        @monitor.alert_users_of_solar_event
      end
    end
    assert_equal "G2", SolarEvent.occurred_on((DateTime.now.utc - 1.day).to_date).expected_storm_strength
  end

  test "should alert users of the strongest event if events occurred yesterday and today" do
    SmsMessagingService.any_instance.expects(:send_message).times(2).with() { |mobile_phone, message| message == OutgoingSmsMessages.storm_prompt(GeomagneticStorm.new("G4")) }
    create_yesterdays_previously_recorded_event("G3")
    SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(Date.yesterday).returns(solar_event("G4", DateTime.now.utc - 1.day))
    SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(Date.today).returns(solar_event("G2", DateTime.now.utc))
    assert_difference 'SolarEvent.count', 1 do
      assert_difference 'AlertPermission.count', 2 do
        @monitor.alert_users_of_solar_event
      end
    end
  end

  test "should create two new solar events if 2 days of solar activity occur since the last time we checked" do
    SmsMessagingService.any_instance.expects(:send_message).times(2).with() { |mobile_phone, message| message == OutgoingSmsMessages.storm_prompt(GeomagneticStorm.new("G3")) }
    SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(Date.yesterday).returns(solar_event("G3", DateTime.now.utc - 1.day))
    SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(Date.today).returns(solar_event("G2", DateTime.now.utc))
    assert_difference 'SolarEvent.count', 2 do
      assert_difference 'AlertPermission.count', 2 do
        @monitor.alert_users_of_solar_event
      end
    end
  end

  test "should not alert users if no solar events occurred yesterday or today" do
    SmsMessagingService.any_instance.expects(:send_message).never
    SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(Date.yesterday).returns(nil)
    SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(Date.today).returns(nil)
    assert_no_difference 'SolarEvent.count' do
      assert_no_difference 'AlertPermission.count' do
        @monitor.alert_users_of_solar_event
      end
    end
  end

  test "should not alert users if no solar events occurred after we sent the alert yesterday" do
    SmsMessagingService.any_instance.expects(:send_message).never
    create_yesterdays_previously_recorded_event("G2")
    SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(Date.yesterday).returns(solar_event("G2", DateTime.now.utc - 1.day))
    SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(Date.today).returns(nil)
    assert_no_difference 'SolarEvent.count' do
      assert_no_difference 'AlertPermission.count' do
        @monitor.alert_users_of_solar_event
      end
    end
  end

  test "should not alert users if a weaker solar event occurred yesterday after the alert went out, and nothing occurred today" do
    SmsMessagingService.any_instance.expects(:send_message).never
    create_yesterdays_previously_recorded_event("G2")
    SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(Date.yesterday).returns(solar_event("G1", DateTime.now.utc - 1.day))
    SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(Date.today).returns(nil)
    assert_no_difference 'SolarEvent.count' do
      assert_no_difference 'AlertPermission.count' do
        @monitor.alert_users_of_solar_event
      end
    end
  end

  test "should replace unapproved alert conditions with new ones if old ones exist" do
    alert_permission = AlertPermission.create!(:user => users(:dan))
    SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(Date.yesterday).returns(nil)
    SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(Date.today).returns(solar_event("G3", DateTime.now.utc))
    assert_difference 'AlertPermission.count', 1 do
      @monitor.alert_users_of_solar_event
    end
    assert_nil AlertPermission.find_by_id(alert_permission)
    assert_not_nil AlertPermission.for_user(users(:dan)).first
  end

  test "should create a new unapproved alert condition if an existing approved one already exists" do
    alert_permission = AlertPermission.create!(:user => users(:dan), :approved_at => Time.now)
    SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(Date.yesterday).returns(nil)
    SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(Date.today).returns(solar_event("G3", DateTime.now.utc))
    assert_difference 'AlertPermission.count', 2 do
      @monitor.alert_users_of_solar_event
    end
    assert_equal 2, AlertPermission.for_user(users(:dan)).count
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
