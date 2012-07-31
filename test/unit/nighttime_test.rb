require 'test_helper'

class NighttimeTest < ActiveSupport::TestCase

  def setup
    @user = users(:john)
    @nighttime = Nighttime.new
  end

  def teardown
    Timecop.return
  end

  # Astronomical Sunrise: Tue, 17 Jul 2012 08:26:00 +0000
  # Astronomical Sunset:  Tue, 17 Jul 2012 04:11:00 +0000

  test "should be nighttime if time is before astronomical sunrise" do
    Timecop.freeze(Time.utc(2012, 7, 17, 8, 25))
    assert @nighttime.nighttime?(@user)
  end

  test "should not be nighttime if time is after astronomical" do
    Timecop.freeze(Time.utc(2012, 7, 17, 8, 27))
    assert !@nighttime.nighttime?(@user)
  end

  test "should not be nighttime if time is before astronomical sunset" do
    Timecop.freeze(Time.utc(2012, 7, 17, 4, 10))
    assert !@nighttime.nighttime?(@user)
  end

  test "should be nighttime if time is after astronomical sunset" do
    Timecop.freeze(Time.utc(2012, 7, 17, 4, 12))
    assert @nighttime.nighttime?(@user)
  end

end
