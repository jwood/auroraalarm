require 'test_helper'

class KpIndexUpdaterTest < ActiveSupport::TestCase

  def setup
    @service = KpIndexUpdater.new
  end

  test "should be able to update the database with kp index forecast data that we have not previously persisted" do
    body = File.read(File.expand_path('../../data/reduced_wingkp_list.txt', __FILE__))
    FakeWeb.register_uri(:get, "http://www.swpc.noaa.gov/wingkp/wingkp_list.txt", :body => body)
    KpForecast.create!(:forecast_time => Time.utc(2012, 7, 17, 21, 13), :expected_kp => 3.33)

    assert_difference 'KpForecast.count', 3 do
      @service.update_kp_index
    end
    last = KpForecast.last
    assert_equal Time.utc(2012, 7, 17, 21, 50), last.forecast_time.to_time
    assert_equal 3.67, last.expected_kp
  end

end
