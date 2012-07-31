require 'test_helper'

class NighttimeTest < ActiveSupport::TestCase

  def setup
    @user = users(:john)
    @nighttime = Nighttime.new
  end

  def teardown
    Timecop.return
  end

  # Sunrise: Tue, 17 Jul 2012 10:43:00 +0000
  # Sunset:  Tue, 17 Jul 2012 01:54:00 +0000

  test "should be nighttime if it is more than 2 hours before sunrise" do
    Timecop.freeze(Time.utc(2012, 7, 17, 8, 42))
    assert @nighttime.nighttime?(@user)
  end

  test "should not be nighttime less than 2 hours before sunrise" do
    Timecop.freeze(Time.utc(2012, 7, 17, 8, 44))
    assert !@nighttime.nighttime?(@user)
  end

  test "should not be nighttime less than 2 hours after sunset" do
    Timecop.freeze(Time.utc(2012, 7, 17, 3, 53))
    assert !@nighttime.nighttime?(@user)
  end

  test "should be nighttime if it is more than 2 hours past sunset" do
    Timecop.freeze(Time.utc(2012, 7, 17, 3, 55))
    assert @nighttime.nighttime?(@user)
  end

end
