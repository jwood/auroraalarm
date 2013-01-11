require 'test_helper'

class KpValueTest < ActiveSupport::TestCase

  test "should be able to determine if the aurora is viewable at certain geomagnetic latitudes" do
    assert KpValue.new(0.99).aurora_viewable_at_geomagnetic_latitude?(66.5)
    assert KpValue.new(1.99).aurora_viewable_at_geomagnetic_latitude?(64.5)
    assert KpValue.new(2.99).aurora_viewable_at_geomagnetic_latitude?(62.4)
    assert KpValue.new(3.99).aurora_viewable_at_geomagnetic_latitude?(60.4)
    assert KpValue.new(4.99).aurora_viewable_at_geomagnetic_latitude?(58.3)
    assert KpValue.new(5.99).aurora_viewable_at_geomagnetic_latitude?(56.3)
    assert KpValue.new(6.99).aurora_viewable_at_geomagnetic_latitude?(54.2)
    assert KpValue.new(7.99).aurora_viewable_at_geomagnetic_latitude?(52.2)
    assert KpValue.new(8.99).aurora_viewable_at_geomagnetic_latitude?(50.1)
    assert KpValue.new(9.99).aurora_viewable_at_geomagnetic_latitude?(48.1)
  end

  test "should be able to determine if the aurora is not viewable at certain geomagnetic latitudes" do
    assert !KpValue.new(0.99).aurora_viewable_at_geomagnetic_latitude?(66.4)
    assert !KpValue.new(1.99).aurora_viewable_at_geomagnetic_latitude?(64.4)
    assert !KpValue.new(2.99).aurora_viewable_at_geomagnetic_latitude?(62.3)
    assert !KpValue.new(3.99).aurora_viewable_at_geomagnetic_latitude?(60.3)
    assert !KpValue.new(4.99).aurora_viewable_at_geomagnetic_latitude?(58.2)
    assert !KpValue.new(5.99).aurora_viewable_at_geomagnetic_latitude?(56.2)
    assert !KpValue.new(6.99).aurora_viewable_at_geomagnetic_latitude?(54.1)
    assert !KpValue.new(7.99).aurora_viewable_at_geomagnetic_latitude?(52.1)
    assert !KpValue.new(8.99).aurora_viewable_at_geomagnetic_latitude?(50.0)
    assert !KpValue.new(9.99).aurora_viewable_at_geomagnetic_latitude?(48.0)
  end

  test "should be able to determine the geomagnetic levels an aurora should be viewable at" do
    assert KpValue.new(6).aurora_viewable_at_geomagnetic_latitude?(66.5)
    assert KpValue.new(6).aurora_viewable_at_geomagnetic_latitude?(62.4)
    assert KpValue.new(6).aurora_viewable_at_geomagnetic_latitude?(58.3)
    assert KpValue.new(6).aurora_viewable_at_geomagnetic_latitude?(54.2)
    assert !KpValue.new(6).aurora_viewable_at_geomagnetic_latitude?(52.2)
    assert !KpValue.new(6).aurora_viewable_at_geomagnetic_latitude?(50.1)
  end

end

