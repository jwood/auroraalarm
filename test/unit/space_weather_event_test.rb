require 'test_helper'

class SpaceWeatherEventTest < ActiveSupport::TestCase

  test "should be able to assign geomagnetic storm level based on the message code" do
    assert_equal "G1", SpaceWeatherEvent.new("WATA20", 123, Time.now.to_s).geomagnetic_storm_level
    assert_equal "G1", SpaceWeatherEvent.new("WARK05", 123, Time.now.to_s).geomagnetic_storm_level
    assert_equal "G1", SpaceWeatherEvent.new("ALTK05", 123, Time.now.to_s).geomagnetic_storm_level

    assert_equal "G2", SpaceWeatherEvent.new("WATA30", 123, Time.now.to_s).geomagnetic_storm_level
    assert_equal "G2", SpaceWeatherEvent.new("WARK06", 123, Time.now.to_s).geomagnetic_storm_level
    assert_equal "G2", SpaceWeatherEvent.new("ALTK06", 123, Time.now.to_s).geomagnetic_storm_level

    assert_equal "G3", SpaceWeatherEvent.new("WATA50", 123, Time.now.to_s).geomagnetic_storm_level
    assert_equal "G3", SpaceWeatherEvent.new("WARK07", 123, Time.now.to_s).geomagnetic_storm_level
    assert_equal "G3", SpaceWeatherEvent.new("ALTK07", 123, Time.now.to_s).geomagnetic_storm_level

    assert_equal "G4", SpaceWeatherEvent.new("WATA99", 123, Time.now.to_s).geomagnetic_storm_level
    assert_equal "G4", SpaceWeatherEvent.new("ALTK08", 123, Time.now.to_s).geomagnetic_storm_level

    assert_equal "G5", SpaceWeatherEvent.new("ALTK09", 123, Time.now.to_s).geomagnetic_storm_level

    assert_equal "", SpaceWeatherEvent.new("FOO123", 123, Time.now.to_s).geomagnetic_storm_level
  end

  test "should be able to specify the geomagnetic storm level" do
    assert_equal "G2", SpaceWeatherEvent.new("WATA20", 123, Time.now.to_s, 0, "G2").geomagnetic_storm_level
  end

  test "should be able to determine the event type based on the message code" do
    assert_equal :watch, SpaceWeatherEvent.new("WATA20", 123, Time.now.to_s).event_type
    assert_equal :warning, SpaceWeatherEvent.new("WARK07", 123, Time.now.to_s).event_type
    assert_equal :alert, SpaceWeatherEvent.new("ALTK07", 123, Time.now.to_s).event_type
    assert_equal :summary, SpaceWeatherEvent.new("SUM123", 123, Time.now.to_s).event_type
    assert_equal :unknown, SpaceWeatherEvent.new("FOO123", 123, Time.now.to_s).event_type
  end

  test "should be able to assign kp index based on the message code" do
    assert_equal 4, SpaceWeatherEvent.new("WARK04", 123, Time.now.to_s).kp_index
    assert_equal 4, SpaceWeatherEvent.new("ALTK04", 123, Time.now.to_s).kp_index

    assert_equal 5, SpaceWeatherEvent.new("WARK05", 123, Time.now.to_s).kp_index
    assert_equal 5, SpaceWeatherEvent.new("ALTK05", 123, Time.now.to_s).kp_index

    assert_equal 6, SpaceWeatherEvent.new("WARK06", 123, Time.now.to_s).kp_index
    assert_equal 6, SpaceWeatherEvent.new("ALTK06", 123, Time.now.to_s).kp_index

    assert_equal 7, SpaceWeatherEvent.new("WARK07", 123, Time.now.to_s).kp_index
    assert_equal 7, SpaceWeatherEvent.new("ALTK07", 123, Time.now.to_s).kp_index

    assert_equal 8, SpaceWeatherEvent.new("ALTK08", 123, Time.now.to_s).kp_index

    assert_equal 9, SpaceWeatherEvent.new("ALTK09", 123, Time.now.to_s).kp_index
  end

  test "should be able to specify the kp index" do
    assert_equal 7, SpaceWeatherEvent.new("WATA20", 123, Time.now.to_s, 7).kp_index
  end

end
