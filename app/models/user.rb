class User < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  attr_accessor :user_location_value

  has_one :user_location, :dependent => :destroy
  has_one :aurora_alert, :dependent => :destroy
  has_many :alert_permissions, :dependent => :destroy

  before_validation :sanitize_mobile_phone

  validates :mobile_phone, :presence => true, :uniqueness => true, :length => { :maximum => 15 }
  validate :validate_mobile_phone_format

  scope :confirmed, -> { where('confirmed_at IS NOT NULL') }

  def confirmed?
    !self.confirmed_at.nil?
  end

  def unapproved_alert_permission
    alert_permissions.unapproved.first
  end

  private

  def sanitize_mobile_phone
    self.mobile_phone = SignalApi::Phone.sanitize(self.mobile_phone)
  end

  def validate_mobile_phone_format
    unless SignalApi::Phone.valid?(self.mobile_phone)
      errors.add(:mobile_phone, "is not valid")
    end
  end

end
