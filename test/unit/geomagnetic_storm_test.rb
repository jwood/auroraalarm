require 'test_helper'

class GeomagneticStormTest < ActiveSupport::TestCase

  test "should be able to get the description of the geomagnetic storm scale" do
    assert_equal "minor",    GeomagneticStorm.new("G1").description
    assert_equal "moderate", GeomagneticStorm.new("G2").description
    assert_equal "strong",   GeomagneticStorm.new("G3").description
    assert_equal "severe",   GeomagneticStorm.new("G4").description
    assert_equal "extreme",  GeomagneticStorm.new("G5").description
  end

end
