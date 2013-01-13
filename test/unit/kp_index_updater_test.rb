require 'test_helper'

class KpIndexUpdaterTest < ActiveSupport::TestCase

  def setup
    Timecop.freeze(Time.utc(2012, 7, 17, 21, 51))
    body = File.read(File.expand_path('../../data/reduced_wingkp_list.txt', __FILE__))
    FakeWeb.register_uri(:get, "http://www.swpc.noaa.gov/wingkp/wingkp_list.txt", body: body)
    @service = KpIndexUpdater.new
  end

  def teardown
    Timecop.return
  end

  test "should be able to update the database with kp index forecast data that we have not previously persisted" do
    KpForecast.create!(forecast_time: Time.utc(2012, 7, 17, 21, 13), expected_kp: 3.33)

    assert_difference 'KpForecast.count', 3 do
      @service.update_kp_index
    end
    last = KpForecast.last
    assert_equal Time.utc(2012, 7, 17, 21, 50), last.forecast_time.to_time
    assert_equal 3.67, last.expected_kp
  end

  test "should remove any old forecast data from the database" do
    old_1 = KpForecast.create!(forecast_time: 11.days.ago, expected_kp: 3.33)
    old_2 = KpForecast.create!(forecast_time: 10.days.ago, expected_kp: 3.33)
    old_3 = KpForecast.create!(forecast_time: 9.days.ago, expected_kp: 3.33)
    old_4 = KpForecast.create!(forecast_time: 8.days.ago, expected_kp: 3.33)
    KpForecast.create!(forecast_time: Time.utc(2012, 7, 17, 21, 13), expected_kp: 3.33)

    assert_difference 'KpForecast.count', -1 do
      @service.update_kp_index
    end
    assert_nil KpForecast.find_by_id(old_1)
    assert_nil KpForecast.find_by_id(old_2)
    assert_nil KpForecast.find_by_id(old_3)
    assert_nil KpForecast.find_by_id(old_4)
  end

end
