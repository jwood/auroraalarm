require 'test_helper'

class GeomagneticStormTest < ActiveSupport::TestCase

  test "should be able to get the description of the geomagnetic storm scale" do
    assert_equal "G1",       GeomagneticStorm.build("G1").scale
    assert_equal "minor",    GeomagneticStorm.build("G1").description
    assert_equal 5,          GeomagneticStorm.build("G1").kp_level

    assert_equal "G2",       GeomagneticStorm.build("G2").scale
    assert_equal "moderate", GeomagneticStorm.build("G2").description
    assert_equal 6,          GeomagneticStorm.build("G2").kp_level

    assert_equal "G3",       GeomagneticStorm.build("G3").scale
    assert_equal "strong",   GeomagneticStorm.build("G3").description
    assert_equal 7,          GeomagneticStorm.build("G3").kp_level

    assert_equal "G4",       GeomagneticStorm.build("G4").scale
    assert_equal "severe",   GeomagneticStorm.build("G4").description
    assert_equal 8,          GeomagneticStorm.build("G4").kp_level

    assert_equal "G5",       GeomagneticStorm.build("G5").scale
    assert_equal "extreme",  GeomagneticStorm.build("G5").description
    assert_equal 9,          GeomagneticStorm.build("G5").kp_level
  end

  test "should return nil if no class could be found for that geomagnetic storm scale" do
    assert_nil GeomagneticStorm.build("G6")
  end

end
