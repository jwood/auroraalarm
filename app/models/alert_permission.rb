class AlertPermission < ActiveRecord::Base
  attr_accessible :user, :approved_at, :expires_at

  validates :user_id, :presence => true
  validate :ensure_only_one_unapproved_alert_permission_per_user

  scope :for_user, lambda { |user| where(:user_id => user) }
  scope :unapproved, where(:approved_at => nil)
  scope :expired, lambda { where(['expires_at < ?', Time.now]) }

  belongs_to :user

  private

  def ensure_only_one_unapproved_alert_permission_per_user
    if self.approved_at.nil? && !AlertPermission.for_user(self.user).unapproved.blank?
      errors.add(:user, "^Only one unapproved alert at a given time is allowed for a user")
    end
  end

end
