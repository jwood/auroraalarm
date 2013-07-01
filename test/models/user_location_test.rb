require 'test_helper'

class UserLocationTest < ActiveSupport::TestCase

  test "should be able to create a user location" do
    assert UserLocation.create!(attributes)
  end

  test "should not be able to create a user location with a duplicate user_id" do
    assert UserLocation.new(attributes(user_id: users(:john).id)).invalid?
  end

  test "should ensure user_id is set" do
    assert UserLocation.new(attributes(user_id: nil)).invalid?
  end

  test "should ensure latitude is set" do
    assert UserLocation.new(attributes(latitude: nil)).invalid?
  end

  test "should ensure longitude is set" do
    assert UserLocation.new(attributes(longitude: nil)).invalid?
  end

  test "should ensure magnetic_latitude is set" do
    assert UserLocation.new(attributes(magnetic_latitude: nil)).invalid?
  end

  test "should strip whitespace from string fields" do
    user_location = UserLocation.create!(user_id: users(:joe).id,
                                         city: "  Tinley Park  ",
                                         state: " IL ",
                                         postal_code: "  60477",
                                         country: "US  ",
                                         latitude: 41.5699614,
                                         longitude: -87.7861711,
                                         magnetic_latitude: 52)

    assert_equal "Tinley Park", user_location.city
    assert_equal "IL", user_location.state
    assert_equal "60477", user_location.postal_code
    assert_equal "US", user_location.country
  end

  private

  def attributes(overrides={})
    {
      user_id: users(:joe).id,
      city: "Tinley Park",
      state: "IL",
      postal_code: "60477",
      country: "US",
      latitude: 41.5699614,
      longitude: -87.7861711,
      magnetic_latitude: 52
    }.merge(overrides)
  end

end
