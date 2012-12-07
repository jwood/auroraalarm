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

    user.confirmed_at = Time.now
    user.save
    assert user.confirmed?
  end

  test "should be able to easily fetch the confirmed users" do
    assert_equal [users(:dan), users(:bob), users(:beth)], User.confirmed
  end

  test "should be able to find the unapproved alert permission for a user, if one exists" do
    user = users(:john)

    assert_nil user.unapproved_alert_permission

    alert_permission = AlertPermission.create!(:user => user)
    assert_equal alert_permission, user.reload.unapproved_alert_permission

    alert_permission.update_attributes(:approved_at => Time.now)
    assert_nil user.reload.unapproved_alert_permission

    alert_permission = AlertPermission.create!(:user => user)
    assert_equal alert_permission, user.reload.unapproved_alert_permission
  end

end
