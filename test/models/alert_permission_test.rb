require 'test_helper'

class AlertPermissionTest < ActiveSupport::TestCase

  test "should be able to create an alert permission" do
    assert AlertPermission.create!(user: users(:john))
  end

  test "should not be able to create an alert permission without a user" do
    assert AlertPermission.new.invalid?
  end

  test "should not be able to create an unapproved alert permission for a user if one already exists" do
    assert AlertPermission.create!(user: users(:john))
    assert AlertPermission.new(user: users(:john)).invalid?
  end

  test "should be able to create a unapproved alert permission if approved alert permissions exist for that user" do
    assert AlertPermission.create!(user: users(:john), approved_at: Time.now)
    assert AlertPermission.create!(user: users(:john), approved_at: Time.now)
    assert AlertPermission.create!(user: users(:john))
  end

  test "should be able to find expired alert permissions" do
    should_find = [
      AlertPermission.create!(user: users(:john), approved_at: Time.now, expires_at: 10.seconds.ago),
      AlertPermission.create!(user: users(:john), approved_at: Time.now, expires_at: 1.minute.ago),
      AlertPermission.create!(user: users(:john), expires_at: 1.minute.ago)
    ]

    AlertPermission.create!(user: users(:dan), approved_at: Time.now, expires_at: 10.seconds.from_now)
    AlertPermission.create!(user: users(:dan), approved_at: Time.now)
    AlertPermission.create!(user: users(:dan))

    alert_permissions = AlertPermission.expired
    assert_equal should_find.size, alert_permissions.size
    should_find.each do |alert_permission|
      assert alert_permissions.include?(alert_permission)
    end
  end

  test "should be able to find active alert permissions" do
    should_find = [
      AlertPermission.create!(user: users(:john), approved_at: Time.now, expires_at: 10.seconds.from_now),
      AlertPermission.create!(user: users(:dan), approved_at: Time.now, expires_at: 1.minute.from_now)
    ]

    AlertPermission.create!(user: users(:dan), approved_at: Time.now, expires_at: 10.seconds.ago)
    AlertPermission.create!(user: users(:dan))
    AlertPermission.create!(user: users(:john), approved_at: Time.now)
    AlertPermission.create!(user: users(:bob), expires_at: 1.hour.from_now)

    alert_permissions = AlertPermission.active
    assert_equal should_find.size, alert_permissions.size
    should_find.each do |alert_permission|
      assert alert_permissions.include?(alert_permission)
    end
  end

  test "should be able to find the ids of users with active alert permissions" do
    should_find = [
      AlertPermission.create!(user: users(:john), approved_at: Time.now, expires_at: 10.seconds.from_now),
      AlertPermission.create!(user: users(:john), approved_at: Time.now, expires_at: 10.minutes.from_now),
      AlertPermission.create!(user: users(:dan), approved_at: Time.now, expires_at: 1.minute.from_now)
    ]

    AlertPermission.create!(user: users(:joe), approved_at: Time.now, expires_at: 10.seconds.ago)
    AlertPermission.create!(user: users(:bob))
    AlertPermission.create!(user: users(:joe), approved_at: Time.now)
    AlertPermission.create!(user: users(:bob), approved_at: Time.now, expires_at: 1.hour.ago)

    assert_equal [users(:john).id, users(:dan).id], AlertPermission.active.distinct_user_ids
  end

  test "should be able to approve an unapproved alert" do
    alert = AlertPermission.create!(user: users(:john))
    assert AlertPermission.unapproved.include?(alert)

    alert.approve!
    assert_not_nil alert.approved_at
    assert_not_nil alert.expires_at
    assert !AlertPermission.unapproved.include?(alert)
  end

end
