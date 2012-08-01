class MessageHistory < ActiveRecord::Base
  self.table_name = "message_history"

  attr_accessible :mobile_phone, :message, :message_type

  validates :mobile_phone, :presence => true
  validates :message, :presence => true
  validates :message_type, :presence => true, :length => { :maximum => 3 }

  validate :ensure_message_type_valid

  private

  def ensure_message_type_valid
    if !["MO", "MT"].include?(self.message_type)
      errors.add(:message_type, "must be MO or MT")
    end
  end

end
