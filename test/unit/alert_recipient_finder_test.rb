require 'test_helper'

class AlertRecipientFinderTest < ActiveSupport::TestCase

  def setup
    users(:john).update_attributes(:confirmed_at => Time.now)
    users(:joe).update_attributes(:confirmed_at => Time.now)
  end

  test "should be able to find all confirmed users with an active alert permission" do
    AlertPermission.create!(:user => users(:bob), :approved_at => Time.now, :expires_at => 10.seconds.from_now)
    AlertPermission.create!(:user => users(:dan), :approved_at => Time.now, :expires_at => 1.minute.ago)

    assert_equal [users(:bob)], AlertRecipientFinder.new.users
  end

  test "should find confirmed users with an active alert permission and an unconfirmed alert" do
    AlertPermission.create!(:user => users(:john), :approved_at => Time.now, :expires_at => 1.minute.from_now)
    AlertPermission.create!(:user => users(:joe), :approved_at => Time.now, :expires_at => 1.minute.from_now)
    AlertPermission.create!(:user => users(:bob), :approved_at => Time.now, :expires_at => 1.minute.from_now)
    AlertPermission.create!(:user => users(:dan), :approved_at => Time.now, :expires_at => 1.minute.from_now)

    aurora_alert = AuroraAlert.create!(:user => users(:joe))
    aurora_alert = AuroraAlert.create!(:user => users(:bob), :confirmed_at => Time.now)
    aurora_alert = AuroraAlert.create!(:user => users(:dan), :confirmed_at => Time.now)

    assert_equal [users(:john), users(:joe)], AlertRecipientFinder.new.users
  end

  test "should find confirmed users with an active alert permission and an unconfirmed alert or an alert that needs a reminder sent" do
    AlertPermission.create!(:user => users(:john), :approved_at => Time.now, :expires_at => 1.minute.from_now)
    AlertPermission.create!(:user => users(:joe), :approved_at => Time.now, :expires_at => 1.minute.from_now)
    AlertPermission.create!(:user => users(:bob), :approved_at => Time.now, :expires_at => 1.minute.from_now)
    AlertPermission.create!(:user => users(:dan), :approved_at => Time.now, :expires_at => 1.minute.from_now)

    aurora_alert = AuroraAlert.create!(:user => users(:joe), :confirmed_at => Time.now)
    aurora_alert = AuroraAlert.create!(:user => users(:bob), :confirmed_at => Time.now, :send_reminder_at => 1.minute.ago)
    aurora_alert = AuroraAlert.create!(:user => users(:dan), :confirmed_at => Time.now, :send_reminder_at => 1.minute.from_now)

    assert_equal [users(:john), users(:bob)], AlertRecipientFinder.new.users
  end

end
