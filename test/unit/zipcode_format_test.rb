require 'test_helper'

class ZipcodeTest < ActiveSupport::TestCase

  test "should consider 5 digit zip codes valid" do
    assert ZipcodeFormat.valid?("90210")
    assert ZipcodeFormat.valid?(" 90210 ")
  end

  test "should consider anything else invalid" do
    assert !ZipcodeFormat.valid?(" ")
    assert !ZipcodeFormat.valid?(nil)
    assert !ZipcodeFormat.valid?(12)
    assert !ZipcodeFormat.valid?(123456)
    assert !ZipcodeFormat.valid?("abc")
  end

end

