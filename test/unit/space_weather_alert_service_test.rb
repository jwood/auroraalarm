require 'test_helper'

class SpaceWeatherAlertServiceTest < ActiveSupport::TestCase

  def setup
    body = File.read(File.expand_path('../../data/space_weather_alerts.html', __FILE__))
    FakeWeb.register_uri(:get, "http://www.swpc.noaa.gov/alerts/archive/alerts_Jun2012.html", :body => body)
  end

  test "should return nil if no geomagnetic storm occurred on that day" do
    service = SpaceWeatherAlertService.new(2012, 6)
    assert_nil service.strongest_geomagnetic_storm(Date.new(2012, 6, 25))
  end

  test "should be able to find the strongest geomagnetic storm that occurred on a given date" do
    service = SpaceWeatherAlertService.new(2012, 6)
    assert_equal "G2", service.strongest_geomagnetic_storm(Date.new(2012, 6, 3)).geomagnetic_storm_level
  end

  test "should return nil if the service times out" do
    Net::HTTP.any_instance.expects(:request).raises(Timeout::Error)
    service = SpaceWeatherAlertService.new(2012, 6)
    assert_nil service.strongest_geomagnetic_storm(Date.new(2012, 6, 25))
  end

end
