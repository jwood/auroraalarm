require 'test_helper'

class KpIndexServiceTest < ActiveSupport::TestCase

  def setup
    @service = KpIndexService.new
  end

  test "should be able to fetch the Kp forecast" do
    body = File.read(File.expand_path('../../../data/wingkp_list.txt', __FILE__))
    FakeWeb.register_uri(:get, "http://www.swpc.noaa.gov/wingkp/wingkp_list.txt", body: body)
    assert_equal [Time.utc(2012, 7, 10, 21, 54), 2.33], @service.current_forecast.first
    assert_equal [Time.utc(2012, 7, 17, 21, 50), 3.67], @service.current_forecast.last
  end

  test "should return an empty array if we could not fetch the data" do
    FakeWeb.register_uri(:get, "http://www.swpc.noaa.gov/wingkp/wingkp_list.txt", body: "")
    assert_equal [], @service.current_forecast
  end

  test "should return an empty array if the service times out" do
    Net::HTTP.any_instance.expects(:request).raises(Timeout::Error)
    FakeWeb.register_uri(:get, "http://www.swpc.noaa.gov/wingkp/wingkp_list.txt", body: "")
    assert_equal [], @service.current_forecast
  end

end
