class UserLocation < ActiveRecord::Base
  attr_accessible :user_id, :user, :city, :state, :postal_code, :country,
                  :latitude, :longitude, :magnetic_latitude

  belongs_to :user

  validates :user_id, :presence => true, :uniqueness => true
  validates :latitude, :presence => true, :numericality => true
  validates :longitude, :presence => true, :numericality => true
  validates :magnetic_latitude, :presence => true, :numericality => true
end
