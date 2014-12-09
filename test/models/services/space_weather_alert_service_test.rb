require 'test_helper'

class SpaceWeatherAlertServiceTest < ActiveSupport::TestCase

  def setup
    body = File.read(File.expand_path('../../../data/alerts.json', __FILE__))
    FakeWeb.register_uri(:get, "http://services.swpc.noaa.gov/products/alerts.json", body: body)
  end

  test "should return nil if no geomagnetic storm occurred on that day" do
    service = SpaceWeatherAlertService.new
    assert_nil service.strongest_geomagnetic_storm(Date.new(2014, 12, 5))
  end

  test "should be able to find the strongest geomagnetic storm that occurred on a given date" do
    service = SpaceWeatherAlertService.new
    assert_equal "G2", service.strongest_geomagnetic_storm(Date.new(2014, 11, 13)).geomagnetic_storm_level
  end

  test "should return nil if the service times out" do
    Net::HTTP.any_instance.expects(:request).raises(Timeout::Error)
    service = SpaceWeatherAlertService.new
    assert_nil service.strongest_geomagnetic_storm(Date.new(2012, 6, 25))
  end

  test "should be able to fetch the alerts" do
    service = SpaceWeatherAlertService.new
    events = service.events
    assert_equal 69, events.length
  end

end
