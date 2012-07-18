require 'test_helper'

class UserTest < ActiveSupport::TestCase

  should "be able to create a new user" do
    user = User.create!(:mobile_phone => "3125551212", :zipcode => zipcodes(:minneapolis))
  end

  should "not be able to create a user with missing info" do
    assert User.new(:zipcode => zipcodes(:minneapolis)).invalid?
    assert User.new(:mobile_phone => "3125551212").invalid?
  end

end
