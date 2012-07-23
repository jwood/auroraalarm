require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "should be able to create a new user" do
    user = User.create!(:mobile_phone => "3125551212")
  end

  test "should not be able to create a user with a duplicate phone number" do
    User.new(:mobile_phone => "3125551200").invalid?
  end

  test "should not be able to create a user with an invalid phone number" do
    User.new(:mobile_phone => "3125551200123123").invalid?
  end

  test "should sanitize the mobile phone" do
    user = User.create!(:mobile_phone => "(312) 555-1212")
    assert_equal "3125551212", user.mobile_phone
  end

  test "should not be able to create a user with an invalid mobile phone" do
    assert User.new(:mobile_phone => "foobar123123").invalid?
  end

  test "should be able to easly tell if a user has been confirmed" do
    user = User.create!(:mobile_phone => "3125551212")
    assert !user.confirmed?

    user.update_attribute(:confirmed_at, Time.now)
    assert user.confirmed?
  end

end
