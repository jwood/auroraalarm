require 'test_helper'

class SpaceWeatherEventTest < ActiveSupport::TestCase

  test "should be able to assign geomagnetic storm level based on the message code" do
    assert_equal "G1", SpaceWeatherEvent.new("WATA20", 123, Time.now.to_s, 0, nil).geomagnetic_storm_level
    assert_equal "G1", SpaceWeatherEvent.new("WARK05", 123, Time.now.to_s, 0, nil).geomagnetic_storm_level
    assert_equal "G1", SpaceWeatherEvent.new("ALTK05", 123, Time.now.to_s, 0, nil).geomagnetic_storm_level

    assert_equal "G2", SpaceWeatherEvent.new("WATA30", 123, Time.now.to_s, 0, nil).geomagnetic_storm_level
    assert_equal "G2", SpaceWeatherEvent.new("WARK06", 123, Time.now.to_s, 0, nil).geomagnetic_storm_level
    assert_equal "G2", SpaceWeatherEvent.new("ALTK06", 123, Time.now.to_s, 0, nil).geomagnetic_storm_level

    assert_equal "G3", SpaceWeatherEvent.new("WATA50", 123, Time.now.to_s, 0, nil).geomagnetic_storm_level
    assert_equal "G3", SpaceWeatherEvent.new("WARK07", 123, Time.now.to_s, 0, nil).geomagnetic_storm_level
    assert_equal "G3", SpaceWeatherEvent.new("ALTK07", 123, Time.now.to_s, 0, nil).geomagnetic_storm_level

    assert_equal "G4", SpaceWeatherEvent.new("WATA99", 123, Time.now.to_s, 0, nil).geomagnetic_storm_level
    assert_equal "G4", SpaceWeatherEvent.new("ALTK08", 123, Time.now.to_s, 0, nil).geomagnetic_storm_level

    assert_equal "G5", SpaceWeatherEvent.new("ALTK09", 123, Time.now.to_s, 0, nil).geomagnetic_storm_level

    assert_equal "", SpaceWeatherEvent.new("FOO123", 123, Time.now.to_s, 0, nil).geomagnetic_storm_level
  end

  test "should be able to specify the geomagnetic storm level" do
    assert_equal "G2", SpaceWeatherEvent.new("WATA20", 123, Time.now.to_s, 0, "G2").geomagnetic_storm_level
  end

  test "should be able to determine the event type based on the message code" do
    assert_equal :watch, SpaceWeatherEvent.new("WATA20", 123, Time.now.to_s, 0, nil).event_type
    assert_equal :warning, SpaceWeatherEvent.new("WARK07", 123, Time.now.to_s, 0, nil).event_type
    assert_equal :alert, SpaceWeatherEvent.new("ALTK07", 123, Time.now.to_s, 0, nil).event_type
    assert_equal :summary, SpaceWeatherEvent.new("SUM123", 123, Time.now.to_s, 0, nil).event_type
    assert_equal :unknown, SpaceWeatherEvent.new("FOO123", 123, Time.now.to_s, 0, nil).event_type
  end

end
