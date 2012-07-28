require 'test_helper'

class AlertPermissionTest < ActiveSupport::TestCase

  test "should be able to create an alert permission" do
    assert AlertPermission.create!(:user => users(:john))
  end

  test "should not be able to create an alert permission without a user" do
    assert AlertPermission.new.invalid?
  end

  test "should not be able to create an alert permission for a user if one already exists" do
    assert AlertPermission.create!(:user => users(:john))
    assert AlertPermission.new(:user => users(:john)).invalid?
  end

end
