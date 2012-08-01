require 'test_helper'

class AlertRecipientFinderTest < ActiveSupport::TestCase

  test "should be able to find all confirmed users with an active alert permission" do
    AlertPermission.create!(:user => users(:bob), :approved_at => Time.now, :expires_at => 10.seconds.from_now)
    AlertPermission.create!(:user => users(:dan), :approved_at => Time.now, :expires_at => 1.minute.ago)

    assert_equal [users(:bob)], AlertRecipientFinder.new.users
  end

end
