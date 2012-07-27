class SolarEvent < ActiveRecord::Base
  attr_accessible :message_code, :serial_number, :issue_time, :expected_storm_strength

  validates :message_code, :presence => true, :length => { :maximum => 15 }
  validates :serial_number, :presence => true, :uniqueness => true, :length => { :maximum => 15 }
  validates :issue_time, :presence => true
  validates :expected_storm_strength, :presence => true, :length => { :maximum => 3 } 

  validate :ensure_only_one_solar_event_per_day

  def self.occurred_on(date)
    where(:issue_time => [date.beginning_of_day..date.end_of_day]).first
  end

  private

  def ensure_only_one_solar_event_per_day
    if self.issue_time && SolarEvent.occurred_on(self.issue_time.to_date)
      errors.add(:issue_time, "^A solar event has already been recorded for this date")
    end
  end

end
