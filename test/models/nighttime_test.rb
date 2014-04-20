require 'test_helper'

class NighttimeTest < ActiveSupport::TestCase

  def setup
    @user = users(:john)
    @nighttime = Nighttime.new
  end

  # Astronomical Sunrise: Tue, 17 Jul 2012 08:26:00 +0000
  # Astronomical Sunset:  Tue, 17 Jul 2012 04:11:00 +0000

  test "should be nighttime if time is before astronomical sunrise" do
    Timecop.freeze(Time.utc(2012, 7, 17, 8, 25)) do
      assert @nighttime.nighttime?(@user)
    end
  end

  test "should not be nighttime if time is after astronomical" do
    Timecop.freeze(Time.utc(2012, 7, 17, 8, 27)) do
      assert !@nighttime.nighttime?(@user)
    end
  end

  test "should not be nighttime if time is before astronomical sunset" do
    Timecop.freeze(Time.utc(2012, 7, 17, 4, 10)) do
      assert !@nighttime.nighttime?(@user)
    end
  end

  test "should be nighttime if time is after astronomical sunset" do
    Timecop.freeze(Time.utc(2012, 7, 17, 4, 12)) do
      assert @nighttime.nighttime?(@user)
    end
  end

  test "should not freak out if the astronomical sunrise or sunset time could not be determined" do
    Timecop.freeze(Time.utc(2014, 4, 20, 17, 35)) do
      assert !@nighttime.nighttime?(users(:beth))
    end
  end

end
