require 'test_helper'

class AuroraConditionsMonitorTest < ActiveSupport::TestCase

  def setup
    FakeWeb.register_uri(:get, "http://www.swpc.noaa.gov/wingkp/wingkp_list.txt", :body => "")
    @monitor = AuroraConditionsMonitor.new

    @bob_permission = AlertPermission.create!(:user => users(:bob), :approved_at => Time.now, :expires_at => 10.minutes.from_now)
    @dan_permission = AlertPermission.create!(:user => users(:dan), :approved_at => Time.now, :expires_at => 10.minutes.from_now)
  end

  test "should send alerts if conditions are optimal" do
    set_kp(9.66); set_nighttime(true); set_moon(:new); set_cloud_cover(10)
    expect_alerts(users(:bob), users(:dan))
    assert_difference 'AuroraAlert.count', 2 do
      @monitor.alert_users_of_aurora_if_conditions_optimal
    end
  end

  test "should not send any alerts if the kp level is not at storm level" do
    set_kp(2.33); set_nighttime(true); set_moon(:new); set_cloud_cover(10)
    no_alerts_expected
    @monitor.alert_users_of_aurora_if_conditions_optimal
  end

  test "should not send any alerts if no confirmed users could be found who had given permission" do
    @bob_permission.destroy
    @dan_permission.destroy

    set_kp(9.66); set_nighttime(true); set_moon(:new); set_cloud_cover(10)
    no_alerts_expected
    @monitor.alert_users_of_aurora_if_conditions_optimal
  end

  test "should only send the alert to users at geomagnetic latitudes that can see the aurora" do
    assert_nil users(:dan).aurora_alert
    set_kp(6.33); set_nighttime(true); set_moon(:new); set_cloud_cover(10)
    expect_alerts(users(:dan))
    assert_difference 'AuroraAlert.count', 1 do
      @monitor.alert_users_of_aurora_if_conditions_optimal
    end
    assert_not_nil users(:dan).reload.aurora_alert
  end

  test "should resend the alert if the user never confirmed the initial one" do
    aurora_alert = AuroraAlert.create!(:user => users(:dan), :confirmed_at => Time.now, :send_reminder_at => 1.minute.ago)
    set_kp(6.33); set_nighttime(true); set_moon(:new); set_cloud_cover(10)
    expect_alerts(users(:dan))
    assert_no_difference 'AuroraAlert.count' do
      @monitor.alert_users_of_aurora_if_conditions_optimal
    end
    aurora_alert.reload
    assert_equal 2, aurora_alert.times_sent
    assert_nil aurora_alert.confirmed_at
    assert_nil aurora_alert.send_reminder_at
  end

  test "should not send any alerts if it is daytime" do
    set_kp(9.66); set_nighttime(false); set_moon(:new); set_cloud_cover(10)
    no_alerts_expected
    @monitor.alert_users_of_aurora_if_conditions_optimal
  end

  test "should not send any alerts on a full moon" do
    set_kp(9.66); set_nighttime(true); set_moon(:full); set_cloud_cover(10)
    no_alerts_expected
    @monitor.alert_users_of_aurora_if_conditions_optimal
  end

  test "should not send any alerts on a waxing gibbous moon" do
    set_kp(9.66); set_nighttime(true); set_moon(:waxing_gibbous); set_cloud_cover(10)
    no_alerts_expected
    @monitor.alert_users_of_aurora_if_conditions_optimal
  end

  test "should not send any alerts on a waning gibbous moon" do
    set_kp(9.66); set_nighttime(true); set_moon(:waning_gibbous); set_cloud_cover(10)
    no_alerts_expected
    @monitor.alert_users_of_aurora_if_conditions_optimal
  end

  test "should not send any alerts if the cloud cover exceeds 20 percent" do
    set_kp(9.66); set_nighttime(true); set_moon(:new); set_cloud_cover(21)
    no_alerts_expected
    @monitor.alert_users_of_aurora_if_conditions_optimal
  end

  private

  def set_kp(kp)
    @monitor.kp_forecaster = Stubs::StubbedKpForecaster.new(kp)
  end

  def set_nighttime(nighttime)
    @monitor.nighttime = Stubs::StubbedNighttime.new(nighttime)
  end

  def set_moon(phase)
    @monitor.moon = Stubs::StubbedMoon.new(phase)
  end

  def set_cloud_cover(percentage)
    @monitor.local_weather_service = Stubs::StubbedLocalWeatherService.new(percentage)
  end

  def expect_alerts(*users)
    users.each do |user|
      SmsMessagingService.any_instance.expects(:send_message).with(user.mobile_phone, OutgoingSmsMessages.aurora_alert)
    end
  end

  def no_alerts_expected
    SmsMessagingService.any_instance.expects(:send_message).never
  end

end
