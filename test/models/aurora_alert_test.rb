require 'test_helper'

class AuroraAlertTest < ActiveSupport::TestCase

  test "should be able to create a new aurora alert" do
    aurora_alert = AuroraAlert.create!(user: users(:john))
    assert_equal 1, aurora_alert.times_sent
    assert_not_nil aurora_alert.first_sent_at
    assert_not_nil aurora_alert.last_sent_at
  end

  test "should not be able to create a new aurora alert with missing information" do
    assert AuroraAlert.new.invalid?
  end

  test "should not be able to create a duplicate aurora alert for the same user" do
    AuroraAlert.create!(user: users(:john))
    assert AuroraAlert.new(user: users(:john)).invalid?
  end

  test "should be able to find alerts that should not be resent" do
    should_not_be_resent = [
      AuroraAlert.create!(user: users(:john), confirmed_at: Time.now.utc),
      AuroraAlert.create!(user: users(:joe), confirmed_at: Time.now.utc, send_reminder_at: 1.minute.from_now)
    ]

    AuroraAlert.create!(user: users(:bob))
    AuroraAlert.create!(user: users(:dan), confirmed_at: Time.now.utc, send_reminder_at: 1.minute.ago)

    assert_equal should_not_be_resent, AuroraAlert.do_not_resend
  end

  test "should be able to find old alerts" do
    old_alerts = [
      AuroraAlert.create!(user: users(:john), first_sent_at: 12.hours.ago),
      AuroraAlert.create!(user: users(:joe), first_sent_at: 12.hours.ago - 1.minute)
    ]

    AuroraAlert.create!(user: users(:bob), first_sent_at: 12.hours.ago + 1.minute)
    AuroraAlert.create!(user: users(:dan), first_sent_at: 12.hours.ago + 2.minutes)

    assert_equal old_alerts, AuroraAlert.old
  end

  test "should be able to destroy old alerts" do
    old_alerts = [
      AuroraAlert.create!(user: users(:john), first_sent_at: 12.hours.ago),
      AuroraAlert.create!(user: users(:joe), first_sent_at: 12.hours.ago - 1.minute)
    ]

    AuroraAlert.create!(user: users(:bob), first_sent_at: 12.hours.ago + 1.minute)
    AuroraAlert.create!(user: users(:dan), first_sent_at: 12.hours.ago + 2.minutes)

    assert_difference 'AuroraAlert.count', -2 do
      AuroraAlert.purge_old_alerts
    end

    old_alerts.each do |old_alert|
      assert_nil AuroraAlert.find_by_id(old_alert)
    end
  end

  test "should be able to mark an existing alert as resent" do
    Timecop.freeze(Time.now) do
      aurora_alert = AuroraAlert.create!(user: users(:john),
                                         last_sent_at: 3.days.ago,
                                         confirmed_at: 3.days.ago,
                                         send_reminder_at: 1.week.from_now)
      assert_equal 1, aurora_alert.times_sent
      assert_equal 3.days.ago, aurora_alert.last_sent_at
      assert_equal 3.days.ago, aurora_alert.confirmed_at
      assert_equal 1.week.from_now, aurora_alert.send_reminder_at

      aurora_alert.mark_as_resent
      assert_equal 2, aurora_alert.times_sent
      assert_equal Time.now.utc, aurora_alert.last_sent_at
      assert_nil aurora_alert.confirmed_at
      assert_nil aurora_alert.send_reminder_at
    end
  end

end
