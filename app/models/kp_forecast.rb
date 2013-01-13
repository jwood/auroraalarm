class KpForecast < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  validates :forecast_time, uniqueness: true, presence: true
  validates :expected_kp, presence: true, numericality: true

  default_scope order(:forecast_time)
  scope :old, -> { where(['forecast_time < ?', 1.week.ago]) }

  def self.current
    where(['forecast_time BETWEEN ? and ?', 15.minutes.ago, Time.now.utc]).last
  end

  def storm_level?
    self.expected_kp >= 4
  end

end
