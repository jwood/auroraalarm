require 'simplecov'
SimpleCov.start 'rails'

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  set_callback :setup, :before, :clear_cache
  set_callback :setup, :before, :disable_web_access

  # Add more helper methods to be used by all tests here...
  def clear_cache
    Rails.cache.clear
  end

  def disable_web_access
    FakeWeb.allow_net_connect = false
    FakeWeb.clean_registry
  end

  def expects_valid_location(location_value)
    loc = GeoKit::GeoLoc.new(:success => true, :lat => 41.5699614, :lng => -87.7861711, :city => "Tinley Park", :state => "IL", :country_code => "US", :zip => "60477")
    loc.success = true
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with(location_value).returns(loc)
  end

  def expects_invalid_location(location_value)
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with(location_value).returns(GeoKit::GeoLoc.new())
  end

  def expects_international_location(location_value)
    loc = GeoKit::GeoLoc.new(:success => true, :lat => 51.5073346, :lng => -0.1276831, :city => "London", :state => "", :country_code => "GB", :zip => "")
    loc.success = true
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with(location_value).returns(loc)
  end

end
