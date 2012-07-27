require 'test_helper'

class SolarEventTest < ActiveSupport::TestCase

  test "should be able to create a new solar event" do
    assert SolarEvent.create!(attributes)
  end

  test "should not be able to create solar event if there is already one recorded for the given day" do
    assert SolarEvent.new(attributes(:issue_time => Time.utc(2012, 7, 5, 12, 23))).invalid?
  end

  test "should not be able to create a solar event with missing required information" do
    assert SolarEvent.new(attributes(:message_code => nil)).invalid?
    assert SolarEvent.new(attributes(:serial_number => nil)).invalid?
    assert SolarEvent.new(attributes(:issue_time => nil)).invalid?
    assert SolarEvent.new(attributes(:expected_storm_strength => nil)).invalid?
  end

  test "should be able to find the strongest solar event that occurred on a specific date" do
    assert_equal solar_events(:g3_2012_07_05), SolarEvent.occurred_on(Time.utc(2012, 7, 5).to_date)
  end

  private

  def attributes(overrides={})
    {
      :message_code => "WATA50",
      :serial_number => "123",
      :issue_time => Time.utc(2012, 6, 10, 12, 30),
      :expected_storm_strength => "G2"
    }.merge(overrides)
  end

end
