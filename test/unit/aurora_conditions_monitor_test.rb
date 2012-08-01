require 'test_helper'

class AuroraConditionsMonitorTest < ActiveSupport::TestCase

  def setup
    body = File.read(File.expand_path('../../data/wingkp_list.txt', __FILE__))
    FakeWeb.register_uri(:get, "http://www.swpc.noaa.gov/wingkp/wingkp_list.txt", :body => "")
    @monitor = AuroraConditionsMonitor.new

    @bob_permission = AlertPermission.create!(:user => users(:bob), :approved_at => Time.now, :expires_at => 10.minutes.from_now)
    @dan_permission = AlertPermission.create!(:user => users(:dan), :approved_at => Time.now, :expires_at => 10.minutes.from_now)
  end

  test "should send alerts if conditions are optimal" do
    set_kp(9.66); set_nighttime(true); set_moon(:new)
    expect_alerts(users(:bob), users(:dan))
    @monitor.alert_users_of_aurora_if_conditions_optimal
  end

  test "should not send any alerts if the kp level is not at storm level" do
    set_kp(2.33); set_nighttime(true); set_moon(:new)
    no_alerts_expected
    @monitor.alert_users_of_aurora_if_conditions_optimal
  end

  test "should not send any alerts if no confirmed users could be found who had given permission" do
    @bob_permission.destroy
    @dan_permission.destroy

    set_kp(9.66); set_nighttime(true); set_moon(:new)
    no_alerts_expected
    @monitor.alert_users_of_aurora_if_conditions_optimal
  end

  test "should only send the alert to users at geomagnetic latitudes that can see the aurora" do
    set_kp(6.33); set_nighttime(true); set_moon(:new)
    expect_alerts(users(:dan))
    @monitor.alert_users_of_aurora_if_conditions_optimal
  end

  test "should not send any alerts if it is daytime" do
    set_kp(9.66); set_nighttime(false); set_moon(:new)
    no_alerts_expected
    @monitor.alert_users_of_aurora_if_conditions_optimal
  end

  test "should not send any alerts on a full moon" do
    set_kp(9.66); set_nighttime(true); set_moon(:full)
    no_alerts_expected
    @monitor.alert_users_of_aurora_if_conditions_optimal
  end

  test "should not send any alerts on a waxing gibbous moon" do
    set_kp(9.66); set_nighttime(true); set_moon(:waxing_gibbous)
    no_alerts_expected
    @monitor.alert_users_of_aurora_if_conditions_optimal
  end

  test "should not send any alerts on a waning gibbous moon" do
    set_kp(9.66); set_nighttime(true); set_moon(:waning_gibbous)
    no_alerts_expected
    @monitor.alert_users_of_aurora_if_conditions_optimal
  end

  private

  def set_kp(kp)
    @monitor.kp_forecaster = StubbedKpForecaster.new(kp)
  end

  def set_nighttime(nighttime)
    @monitor.nighttime = StubbedNighttime.new(nighttime)
  end

  def set_moon(phase)
    @monitor.moon = StubbedMoon.new(phase)
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
