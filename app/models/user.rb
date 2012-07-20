class User < ActiveRecord::Base
  attr_accessible :mobile_phone, :zipcode, :zipcode_value
  attr_accessor :zipcode_value

  belongs_to :zipcode

  before_validation :sanitize_mobile_phone

  validates :mobile_phone, :presence => true, :uniqueness => true, :length => { :maximum => 15 }
  validate :validate_mobile_phone_format
  validate :validate_zipcode

  private

  def sanitize_mobile_phone
    self.mobile_phone = SignalApi::Phone.sanitize(self.mobile_phone)
  end

  def validate_mobile_phone_format
    unless SignalApi::Phone.valid?(self.mobile_phone)
      errors.add(:mobile_phone, "is not valid")
    end
  end

  def validate_zipcode
    if zipcode.blank?
      errors.add(:zipcode_value, "^Zipcode is not valid")
    end
  end

end
