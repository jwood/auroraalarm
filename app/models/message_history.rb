class MessageHistory < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  self.table_name = "message_history"

  validates :mobile_phone, :presence => true
  validates :message, :presence => true
  validates :message_type, :presence => true, :length => { :maximum => 3 }

  validate :ensure_message_type_valid

  scope :old, -> { where(['created_at < ?', 2.weeks.ago]) }

  def self.purge_old_messages
    MessageHistory.old.destroy_all
  end

  private

  def ensure_message_type_valid
    if !["MO", "MT"].include?(self.message_type)
      errors.add(:message_type, "must be MO or MT")
    end
  end

end
