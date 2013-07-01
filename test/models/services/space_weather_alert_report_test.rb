require 'test_helper'

class SpaceWeatherAlertReportTest < ActiveSupport::TestCase

  def setup
    report_text = File.read(File.expand_path('../../../data/space_weather_alerts.html', __FILE__))
    @report = SpaceWeatherAlertReport.new(report_text)
  end

  test "should be able to parse the report into an array of events" do
    events = @report.events
    assert_equal 83, events.size

    event = events[0]
    assert_equal "WARK04", event.message_code
    assert_equal "1954", event.serial_number
    assert_equal Time.utc(2012, 6, 30, 23, 49), event.issue_time
    assert_equal 4, event.kp_index
    assert_equal :warning, event.event_type

    event = events[5]
    assert_equal "ALTEF3", event.message_code
    assert_equal "1923", event.serial_number
    assert_equal Time.utc(2012, 6, 24, 10, 11), event.issue_time
    assert_equal 0, event.kp_index
    assert_equal :alert, event.event_type

    event = events[81]
    assert_equal "WARK04", event.message_code
    assert_equal "1935", event.serial_number
    assert_equal Time.utc(2012, 6, 02, 22, 24), event.issue_time
    assert_equal 4, event.kp_index
    assert_equal :warning, event.event_type

    event = events[82]
    assert_equal "ALTTP2", event.message_code
    assert_equal "796", event.serial_number
    assert_equal Time.utc(2012, 6, 1, 23, 14), event.issue_time
    assert_equal 0, event.kp_index
    assert_equal :alert, event.event_type
  end

  test "should be able to find all events for a given date" do
    events = @report.find_events(date: Date.new(2012, 6, 17))
    assert_equal 11, events.size

    event = events[0]
    assert_equal "WARK04", event.message_code
    assert_equal "1950", event.serial_number
    assert_equal Time.utc(2012, 6, 17, 23, 54), event.issue_time
    assert_equal 4, event.kp_index
    assert_equal :warning, event.event_type

    event = events[5]
    assert_equal "ALTK06", event.message_code
    assert_equal "286", event.serial_number
    assert_equal Time.utc(2012, 6, 17, 11, 33), event.issue_time
    assert_equal 6, event.kp_index
    assert_equal :alert, event.event_type

    event = events[10]
    assert_equal "WARK04", event.message_code
    assert_equal "1947", event.serial_number
    assert_equal Time.utc(2012, 6, 17, 2, 32), event.issue_time
    assert_equal 4, event.kp_index
    assert_equal :warning, event.event_type
  end

  test "should be able to find all events for a given event type" do
    events = @report.find_events(event_type: :watch)
    assert_equal 4, events.size

    event = events[0]
    assert_equal "WATA20", event.message_code
    assert_equal "494", event.serial_number
    assert_equal Time.utc(2012, 6, 14, 21, 05), event.issue_time
    assert_equal 0, event.kp_index
    assert_equal :watch, event.event_type
    assert_equal "G1", event.geomagnetic_storm_level

    event = events[3]
    assert_equal "WATA20", event.message_code
    assert_equal "492", event.serial_number
    assert_equal Time.utc(2012, 6, 3, 19, 47), event.issue_time
    assert_equal 0, event.kp_index
    assert_equal :watch, event.event_type
    assert_equal "G1", event.geomagnetic_storm_level
  end

  test "should be able to find all events of a given type on a given day" do
    events = @report.find_events(date: Date.new(2012, 6, 14), event_type: :watch)
    assert_equal 1, events.size

    event = events[0]
    assert_equal "WATA20", event.message_code
    assert_equal "494", event.serial_number
    assert_equal Time.utc(2012, 6, 14, 21, 05), event.issue_time
    assert_equal 0, event.kp_index
    assert_equal :watch, event.event_type
    assert_equal "G1", event.geomagnetic_storm_level
  end

  test "should not freak out if the report data is blank" do
    report = SpaceWeatherAlertReport.new("")
  end

  test "should not freak out if the report data does not contain any events" do
    report_text = File.read(File.expand_path('../../../data/space_weather_alerts_no_events.html', __FILE__))
    report = SpaceWeatherAlertReport.new(report_text)
  end

end
