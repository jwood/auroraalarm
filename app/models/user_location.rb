class UserLocation < ActiveRecord::Base
  include BelongsToUser

  before_validation :strip_data

  validates :user_id, presence: true, uniqueness: true
  validates :latitude, presence: true, numericality: true
  validates :longitude, presence: true, numericality: true
  validates :magnetic_latitude, presence: true, numericality: true

  private

  def strip_data
    [:city, :state, :postal_code, :country].each do |attr|
      current_value = self.public_send(attr)
      self.public_send("#{attr}=", current_value.strip) unless current_value.nil?
    end
  end
end
