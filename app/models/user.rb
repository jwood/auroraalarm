class User < ActiveRecord::Base
  attr_accessible :mobile_phone, :user_location, :user_location_value
  attr_accessor :user_location_value

  has_one :user_location, :dependent => :destroy
  has_one :alert_permission, :dependent => :destroy

  before_validation :sanitize_mobile_phone

  validates :mobile_phone, :presence => true, :uniqueness => true, :length => { :maximum => 15 }
  validate :validate_mobile_phone_format

  scope :confirmed, where('confirmed_at IS NOT NULL')

  def confirmed?
    !self.confirmed_at.nil?
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
