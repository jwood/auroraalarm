class Zipcode < ActiveRecord::Base
  attr_accessible :code, :latitude, :longitude, :magnetic_latitude

  has_many :users

  validates :code, :presence => true, :uniqueness => true, :length => { :maximum => 25 }
  validates :latitude, :presence => true, :numericality => true
  validates :longitude, :presence => true, :numericality => true
  validates :magnetic_latitude, :presence => true, :numericality => true
end
