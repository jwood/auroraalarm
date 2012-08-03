class AuroraAlert < ActiveRecord::Base
  include BelongsToUser

  attr_accessible :user, :first_sent_at, :last_sent_at, :times_sent, :confirmed_at, :send_reminder_at

  validates :user_id, :uniqueness => true, :presence => true
  validates :first_sent_at, :presence => true, :uniqueness => true
  validates :times_sent, :presence => true, :numericality => true

  before_validation :set_first_sent_at

  scope :do_not_resend, lambda { where(['confirmed_at IS NOT NULL AND (send_reminder_at IS NULL OR send_reminder_at > ?)', Time.now.utc]) }

  private

  def set_first_sent_at
    if self.first_sent_at.nil?
      self.first_sent_at = Time.now.utc
    end
  end

end
