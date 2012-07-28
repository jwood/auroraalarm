require 'test_helper'

class AlertPermissionTest < ActiveSupport::TestCase

  test "should be able to create an alert permission" do
    assert AlertPermission.create!(:user => users(:john))
  end

  test "should not be able to create an alert permission without a user" do
    assert AlertPermission.new.invalid?
  end

  test "should not be able to create an unapproved alert permission for a user if one already exists" do
    assert AlertPermission.create!(:user => users(:john))
    assert AlertPermission.new(:user => users(:john)).invalid?
  end

  test "should be able to create a unapproved alert permission if approved alert permissions exist for that user" do
    assert AlertPermission.create!(:user => users(:john), :approved_at => Time.now)
    assert AlertPermission.create!(:user => users(:john), :approved_at => Time.now)
    assert AlertPermission.create!(:user => users(:john))
  end

  test "should be able to find expired alert permissions" do
    should_find = [
      AlertPermission.create!(:user => users(:john), :approved_at => Time.now, :expires_at => 10.seconds.ago),
      AlertPermission.create!(:user => users(:john), :approved_at => Time.now, :expires_at => 1.minute.ago),
      AlertPermission.create!(:user => users(:john), :expires_at => 1.minute.ago)
    ]

    AlertPermission.create!(:user => users(:dan), :approved_at => Time.now, :expires_at => 10.seconds.from_now)
    AlertPermission.create!(:user => users(:dan), :approved_at => Time.now)
    AlertPermission.create!(:user => users(:dan))

    alert_permissions = AlertPermission.expired
    assert_equal should_find.size, alert_permissions.size
    should_find.each do |alert_permission|
      assert alert_permissions.include?(alert_permission)
    end
  end

end
