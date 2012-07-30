require 'test_helper'

class KpForecastTest < ActiveSupport::TestCase

  test "should be able to create a new kp forecast" do
    t = Time.now
    kp_forecast = KpForecast.create!(:forecast_time => t, :expected_kp => 4.33)
    assert_equal t, kp_forecast.forecast_time
    assert_equal 4.33, kp_forecast.expected_kp
  end

  test "should not be able to create a kp forecast with missing or invalid data" do
    assert KpForecast.new(:forecast_time => Time.now).invalid?
    assert KpForecast.new(:expected_kp => 4.33).invalid?
    assert KpForecast.new(:forecast_time => Time.now, :expected_kp => 'abc').invalid?
  end

  test "should not be able to create a kp_forecast for a time that has already been recorded" do
    t = Time.now
    KpForecast.create!(:forecast_time => t, :expected_kp => 4.33)
    assert KpForecast.new(:forecast_time => t, :expected_kp => 4.33).invalid?
  end

  test "should be able to find old forecast data" do
    old_1 = KpForecast.create!(:forecast_time => 9.days.ago, :expected_kp => 3.33)
    old_2 = KpForecast.create!(:forecast_time => 8.days.ago, :expected_kp => 3.33)
    old_3 = KpForecast.create!(:forecast_time => 7.days.ago, :expected_kp => 3.33)
    KpForecast.create!(:forecast_time => 6.days.ago, :expected_kp => 3.33)
    KpForecast.create!(:forecast_time => 5.days.ago, :expected_kp => 3.33)
    KpForecast.create!(:forecast_time => 4.days.ago, :expected_kp => 3.33)

    old = KpForecast.old
    assert_equal 3, old.size
    assert old.include?(old_1)
    assert old.include?(old_2)
    assert old.include?(old_3)
  end

  test "should be able to find the current forecast data" do
    KpForecast.create!(:forecast_time => 14.minutes.ago, :expected_kp => 4.33)
    kp_forecast = KpForecast.create!(:forecast_time => 1.minute.ago, :expected_kp => 4.33)
    assert_equal kp_forecast, KpForecast.current
  end

  test "should return nil if there is no forecast data for the current time period" do
    KpForecast.create!(:forecast_time => 16.minutes.ago, :expected_kp => 4.33)
    assert_nil KpForecast.current
  end

  test "should be able to tell if the Kp index is at or exceeds storm level" do
    assert !KpForecast.new(:forecast_time => Time.now, :expected_kp => 3.99).storm_level?
    assert KpForecast.new(:forecast_time => Time.now, :expected_kp => 4.00).storm_level?
    assert KpForecast.new(:forecast_time => Time.now, :expected_kp => 4.01).storm_level?
  end

end
