require 'test_helper'

class LocalWeatherServiceTest < ActiveSupport::TestCase

  def setup
    @service = LocalWeatherService.new
  end

  test "should be able to get the cloud cover percentage for a user" do
    body = File.read(File.expand_path('../../data/local_weather.xml', __FILE__))
    FakeWeb.register_uri(:get, "http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdXMLclient.php?lat=44.9061358&lon=-93.2885455&product=time-series&Unit=e&sky=sky", :body => body)
    assert_equal 11, @service.cloud_cover_percentage(users(:john))
  end

  test "should return nil if no data was returned from the web service" do
    FakeWeb.register_uri(:get, "http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdXMLclient.php?lat=44.9061358&lon=-93.2885455&product=time-series&Unit=e&sky=sky", :body => "")
    assert_nil @service.cloud_cover_percentage(users(:john))
  end

  test "should return nil if the service times out" do
    Net::HTTP.any_instance.expects(:request).raises(Timeout::Error)
    FakeWeb.register_uri(:get, "http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdXMLclient.php?lat=44.9061358&lon=-93.2885455&product=time-series&Unit=e&sky=sky", :body => "")
    assert_nil @service.cloud_cover_percentage(users(:john))
  end

end
