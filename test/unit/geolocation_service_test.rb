require 'test_helper'

class GeolocationServiceTest < ActiveSupport::TestCase

  def setup
    FakeWeb.allow_net_connect = false
    FakeWeb.clean_registry
    @service = GeolocationService.new
  end

  def teardown
    FakeWeb.allow_net_connect = true
  end

  should "properly calculate the magnetic latitude for a zip code" do
    # Caribou, ME
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with("04736").returns(stub(:lat => 46.9092987, :lng => -68.0069732))
    assert_equal 55, @service.magnetic_latitude("04736")

    # Minneapolis, MN
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with("55419").returns(stub(:lat => 44.9061358, :lng => -93.2885455))
    assert_equal 56, @service.magnetic_latitude("55419")

    # Tinley Park, IL
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with("60477").returns(stub(:lat => 41.5699614, :lng => -87.7861711))
    assert_equal 52, @service.magnetic_latitude("60477")

    # Beverly Hills, CA
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with("90210").returns(stub(:lat => 34.1030032, :lng => -118.4104684))
    assert_equal 42, @service.magnetic_latitude("90210")

    # Corpus Christi, TX
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with("78402").returns(stub(:lat => 27.8261595, :lng => -97.4002872))
    assert_equal 39, @service.magnetic_latitude("78402")

    # Miami, FL
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with("33111").returns(stub(:lat => 25.77, :lng => -80.19))
    assert_equal 37, @service.magnetic_latitude("33111")
  end

end
