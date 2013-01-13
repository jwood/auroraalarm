class AlertPermission < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include BelongsToUser

  validates :user_id, :presence => true
  validate :ensure_only_one_unapproved_alert_permission_per_user

  scope :unapproved, -> { where(:approved_at => nil) }
  scope :expired, -> { where(['expires_at < ?', Time.now]) }
  scope :active, -> { where(['approved_at IS NOT NULL AND expires_at > ?', Time.now]) }

  private

  def ensure_only_one_unapproved_alert_permission_per_user
    if self.approved_at.nil? && !AlertPermission.for_user(self.user).unapproved.blank?
      errors.add(:user, "^Only one unapproved alert at a given time is allowed for a user")
    end
  end

end
