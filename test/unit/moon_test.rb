require 'test_helper'

class AuroraConditionsMonitorTest < ActiveSupport::TestCase

  test "should be able to get the phase of the moon" do
    assert_equal :first_quarter,   Moon.new.phase(Date.new(2012, 1, 1).to_time)
    assert_equal :waxing_gibbous,  Moon.new.phase(Date.new(2012, 1, 4).to_time)
    assert_equal :full,            Moon.new.phase(Date.new(2012, 1, 8).to_time)
    assert_equal :waning_gibbous,  Moon.new.phase(Date.new(2012, 1, 12).to_time)
    assert_equal :third_quarter,   Moon.new.phase(Date.new(2012, 1, 16).to_time)
    assert_equal :waning_crescent, Moon.new.phase(Date.new(2012, 1, 20).to_time)
    assert_equal :new,             Moon.new.phase(Date.new(2012, 1, 24).to_time)
    assert_equal :waxing_crescent, Moon.new.phase(Date.new(2012, 1, 28).to_time)
  end

end
