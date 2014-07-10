require 'test_helper'

class CleanupServiceTest < ActiveSupport::TestCase

  test "should be able to perform any necessary cleanup" do
    AuroraAlert.create!(user: users(:john), first_sent_at: 12.hours.ago)
    assert_difference 'MessageHistory.count', -2 do
      assert_difference 'AuroraAlert.count', -1 do
        CleanupService.execute
      end
    end
  end

end
