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

end
