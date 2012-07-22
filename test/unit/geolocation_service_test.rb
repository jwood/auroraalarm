require 'test_helper'

class GeolocationServiceTest < ActiveSupport::TestCase

  def setup
    @service = GeolocationService.new
  end

  should "be able to fetch the data for a location" do
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with("60477").returns(
      GeoKit::GeoLoc.new(:city => "Tinley Park", :state => "IL", :zip => "60477", :country_code => "US", :lat => 46.9092987, :lng => -68.0069732))
    location = @service.geocode("60477")
    assert_equal "Tinley Park", location.city
    assert_equal "IL", location.state
    assert_equal "60477", location.zip
    assert_equal "US", location.country_code
    assert_equal 46.9092987, location.latitude
    assert_equal -68.0069732, location.longitude
  end

  should "properly calculate the magnetic latitude for a zip code" do
    # Caribou, ME
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with("04736").returns(GeoKit::GeoLoc.new(:lat => 46.9092987, :lng => -68.0069732))
    assert_equal 55, @service.geocode("04736").magnetic_latitude

    # Minneapolis, MN
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with("55419").returns(GeoKit::GeoLoc.new(:lat => 44.9061358, :lng => -93.2885455))
    assert_equal 56, @service.geocode("55419").magnetic_latitude

    # Tinley Park, IL
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with("60477").returns(GeoKit::GeoLoc.new(:lat => 41.5699614, :lng => -87.7861711))
    assert_equal 52, @service.geocode("60477").magnetic_latitude

    # Beverly Hills, CA
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with("90210").returns(GeoKit::GeoLoc.new(:lat => 34.1030032, :lng => -118.4104684))
    assert_equal 42, @service.geocode("90210").magnetic_latitude

    # Corpus Christi, TX
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with("78402").returns(GeoKit::GeoLoc.new(:lat => 27.8261595, :lng => -97.4002872))
    assert_equal 39, @service.geocode("78402").magnetic_latitude

    # Miami, FL
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with("33111").returns(GeoKit::GeoLoc.new(:lat => 25.77, :lng => -80.19))
    assert_equal 37, @service.geocode("33111").magnetic_latitude
  end

end
