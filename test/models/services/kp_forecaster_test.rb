require 'test_helper'

class KpForecasterTest < ActiveSupport::TestCase

  def setup
    Timecop.freeze(Time.utc(2012, 7, 17, 21, 51))
    body = File.read(File.expand_path('../../../data/reduced_wingkp_list.txt', __FILE__))
    FakeWeb.register_uri(:get, "http://www.swpc.noaa.gov/wingkp/wingkp_list.txt", body: body)
    @service = KpForecaster.new
  end

  def teardown
    Timecop.return
  end

  test "should return the current kp forecast" do
    kp_forecast = @service.current_kp_forecast
    assert_equal Time.utc(2012, 7, 17, 21, 50), kp_forecast.forecast_time.to_time
    assert_equal 3.67, kp_forecast.expected_kp
  end

end

