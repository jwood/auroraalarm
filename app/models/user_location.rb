class UserLocation < ActiveRecord::Base
  include BelongsToUser

  attr_accessible :user_id, :user, :city, :state, :postal_code, :country,
                  :latitude, :longitude, :magnetic_latitude

  validates :user_id, :presence => true, :uniqueness => true
  validates :latitude, :presence => true, :numericality => true
  validates :longitude, :presence => true, :numericality => true
  validates :magnetic_latitude, :presence => true, :numericality => true
end
