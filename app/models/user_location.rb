class UserLocation < ActiveRecord::Base
  include BelongsToUser

  validates :user_id, presence: true, uniqueness: true
  validates :latitude, presence: true, numericality: true
  validates :longitude, presence: true, numericality: true
  validates :magnetic_latitude, presence: true, numericality: true
end
