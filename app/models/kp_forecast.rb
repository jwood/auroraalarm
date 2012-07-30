class KpForecast < ActiveRecord::Base
  attr_accessible :forecast_time, :expected_kp

  validates :forecast_time, :uniqueness => true, :presence => true
  validates :expected_kp, :presence => true, :numericality => true

  default_scope order(:forecast_time)
  scope :old, lambda { where(['forecast_time < ?', 1.week.ago]) }
end
