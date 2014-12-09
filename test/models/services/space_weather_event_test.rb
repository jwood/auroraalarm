require 'test_helper'

class SpaceWeatherEventTest < ActiveSupport::TestCase

  test "should be able to assign geomagnetic storm level based on the message code" do
    assert_equal "G1", SpaceWeatherEvent.new(create_event_data("WATA20", "123")).geomagnetic_storm_level
    assert_equal "G1", SpaceWeatherEvent.new(create_event_data("WARK05", "123")).geomagnetic_storm_level
    assert_equal "G1", SpaceWeatherEvent.new(create_event_data("ALTK05", "123")).geomagnetic_storm_level

    assert_equal "G2", SpaceWeatherEvent.new(create_event_data("WATA30", "123")).geomagnetic_storm_level
    assert_equal "G2", SpaceWeatherEvent.new(create_event_data("WARK06", "123")).geomagnetic_storm_level
    assert_equal "G2", SpaceWeatherEvent.new(create_event_data("ALTK06", "123")).geomagnetic_storm_level

    assert_equal "G3", SpaceWeatherEvent.new(create_event_data("WATA50", "123")).geomagnetic_storm_level
    assert_equal "G3", SpaceWeatherEvent.new(create_event_data("WARK07", "123")).geomagnetic_storm_level
    assert_equal "G3", SpaceWeatherEvent.new(create_event_data("ALTK07", "123")).geomagnetic_storm_level

    assert_equal "G4", SpaceWeatherEvent.new(create_event_data("WATA99", "123")).geomagnetic_storm_level
    assert_equal "G4", SpaceWeatherEvent.new(create_event_data("ALTK08", "123")).geomagnetic_storm_level

    assert_equal "G5", SpaceWeatherEvent.new(create_event_data("ALTK09", "123")).geomagnetic_storm_level

    assert_equal "", SpaceWeatherEvent.new(create_event_data("FOO123", "123")).geomagnetic_storm_level
  end

  test "should be able to specify the geomagnetic storm level" do
    assert_equal "G2", SpaceWeatherEvent.new(create_event_data("WATA20", "123"), 0, "G2").geomagnetic_storm_level
  end

  test "should be able to determine the event type based on the message code" do
    assert_equal :watch, SpaceWeatherEvent.new(create_event_data("WATA20", "123")).event_type
    assert_equal :warning, SpaceWeatherEvent.new(create_event_data("WARK07", "123")).event_type
    assert_equal :alert, SpaceWeatherEvent.new(create_event_data("ALTK07", "123")).event_type
    assert_equal :summary, SpaceWeatherEvent.new(create_event_data("SUM123", "123")).event_type
    assert_equal :unknown, SpaceWeatherEvent.new(create_event_data("FOO123", "123")).event_type
  end

  test "should be able to assign kp index based on the message code" do
    assert_equal 4, SpaceWeatherEvent.new(create_event_data("WARK04", "123")).kp_index
    assert_equal 4, SpaceWeatherEvent.new(create_event_data("ALTK04", "123")).kp_index

    assert_equal 5, SpaceWeatherEvent.new(create_event_data("WARK05", "123")).kp_index
    assert_equal 5, SpaceWeatherEvent.new(create_event_data("ALTK05", "123")).kp_index

    assert_equal 6, SpaceWeatherEvent.new(create_event_data("WARK06", "123")).kp_index
    assert_equal 6, SpaceWeatherEvent.new(create_event_data("ALTK06", "123")).kp_index

    assert_equal 7, SpaceWeatherEvent.new(create_event_data("WARK07", "123")).kp_index
    assert_equal 7, SpaceWeatherEvent.new(create_event_data("ALTK07", "123")).kp_index

    assert_equal 8, SpaceWeatherEvent.new(create_event_data("ALTK08", "123")).kp_index

    assert_equal 9, SpaceWeatherEvent.new(create_event_data("ALTK09", "123")).kp_index
  end

  test "should be able to specify the kp index" do
    assert_equal 7, SpaceWeatherEvent.new(create_event_data("WATA20", "123"), 7).kp_index
  end

end
