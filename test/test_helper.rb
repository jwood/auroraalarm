require 'coveralls'
Coveralls.wear! 'rails'

require 'simplecov'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'mocha/setup'

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
    FakeWeb.allow_net_connect = %r[coveralls.io]
    FakeWeb.clean_registry
  end

  def expects_valid_location(location_value)
    loc = Geokit::GeoLoc.new(success: true, lat: 41.5699614, lng: -87.7861711, city: "Tinley Park", state: "IL", country_code: "US", zip: "60477")
    loc.success = true
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with(location_value).returns(loc)
  end

  def expects_invalid_location(location_value)
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with(location_value).returns(Geokit::GeoLoc.new())
  end

  def expects_international_location(location_value)
    loc = Geokit::GeoLoc.new(success: true, lat: 19.436516, lng: -99.1739857, city: "Ciudad De Mexico", state: "D.F.", country_code: "MX", zip: "11300")
    loc.success = true
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with(location_value).returns(loc)
  end

  def assert_new_user
    assert_difference 'User.count', 1 do
      assert_difference 'UserLocation.count', 1 do
        yield
      end
    end
  end

  def assert_no_new_user
    assert_no_difference 'User.count' do
      assert_no_difference 'UserLocation.count' do
        yield
      end
    end
  end

  def assert_user_deleted
    assert_difference 'User.count', -1 do
      assert_difference 'UserLocation.count', -1 do
        yield
      end
    end
  end

  def assert_time_roughly(expected, actual, deviation = 5.seconds)
    low, high = expected - deviation, expected + deviation
    assert(actual >= low && actual <= high, "Expected time within #{deviation} seconds of #{expected} but was #{actual}")
  end

  def solar_event(strength, issue_time)
    SpaceWeatherEvent.new(create_event_data("WATA050", new_serial_number, issue_time.to_s), 0, strength)
  end

  def create_event_data(code, serial_number, issue_time="2014-12-09 19:23:50.023")
    {
      "product_id" => "K04W",
      "issue_datetime" => issue_time,
      "message" => "Space Weather Message Code: #{code}\r\nSerial Number: #{serial_number}\r\nIssue Time: #{issue_time}"
    }
  end

  def new_serial_number
    @@serial_number ||= 1000
    @@serial_number += 1
  end

end
