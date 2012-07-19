require 'test_helper'

class ZipcodeTest < ActiveSupport::TestCase

  test "should be able to store zip code information in the database" do
    zipcode = Zipcode.create!(:code => "60606", :latitude => 41.5699614, :longitude => -87.7861711, :magnetic_latitude => 52)
    assert_equal "60606", zipcode.code
    assert_equal 41.5699614, zipcode.latitude
    assert_equal -87.7861711, zipcode.longitude
    assert_equal 52, zipcode.magnetic_latitude
  end

  test "should not be able to create a duplciate zip code entry" do
    assert Zipcode.new(:code => "55419", :latitude => 44.9061358, :longitude => -93.2885455, :magnetic_latitude => 56).invalid?
  end

  test "should not be able to create a zip code with missing information" do
    assert Zipcode.new(:latitude => 44.9061358, :longitude => -93.2885455, :magnetic_latitude => 56).invalid?
    assert Zipcode.new(:code => "55419", :longitude => -93.2885455, :magnetic_latitude => 56).invalid?
    assert Zipcode.new(:code => "55419", :latitude => 44.9061358, :magnetic_latitude => 56).invalid?
    assert Zipcode.new(:code => "55419", :latitude => 44.9061358, :longitude => -93.2885455).invalid?
  end

  test "should be able to create a zip code with geolocation data" do
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with("60477").returns(GeoKit::GeoLoc.new(:lat => 41.5699614, :lng => -87.7861711))
    zipcode = Zipcode.find_or_create_with_geolocation_data("60477")
    assert_equal "60477", zipcode.code
    assert_equal 41.5699614, zipcode.latitude
    assert_equal -87.7861711, zipcode.longitude
    assert_equal 52, zipcode.magnetic_latitude
  end

  test "should be able to find an existing zip code" do
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).never
    assert_equal zipcodes(:minneapolis), Zipcode.find_or_create_with_geolocation_data("55419")
  end

  test "should only allow 5 digit US zip codes" do
    assert Zipcode.new(:code => "abcde", :latitude => 41.5699614, :longitude => -87.7861711, :magnetic_latitude => 52).invalid?
    assert Zipcode.new(:code => "12345-1234", :latitude => 41.5699614, :longitude => -87.7861711, :magnetic_latitude => 52).invalid?
  end

end
