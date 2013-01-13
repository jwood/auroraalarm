class AuroraAlert < ActiveRecord::Base
  include BelongsToUser

  attr_accessible :user, :first_sent_at, :last_sent_at, :times_sent, :confirmed_at, :send_reminder_at

  validates :user_id, :uniqueness => true, :presence => true
  validates :first_sent_at, :presence => true, :uniqueness => true
  validates :times_sent, :presence => true, :numericality => true

  before_validation :set_first_sent_at
  before_validation :set_last_sent_at

  scope :do_not_resend, -> { where(['confirmed_at IS NOT NULL AND (send_reminder_at IS NULL OR send_reminder_at > ?)', Time.now.utc]) }
  scope :old, -> { where(['first_sent_at < ?', 12.hours.ago]) }

  def self.purge_old_alerts
    AuroraAlert.old.destroy_all
  end

  private

  def set_first_sent_at
    if self.first_sent_at.nil?
      self.first_sent_at = Time.now.utc
    end
  end

  def set_last_sent_at
    if self.last_sent_at.nil?
      self.last_sent_at = Time.now.utc
    end
  end

end
