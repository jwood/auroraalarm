class User < ActiveRecord::Base
  attr_accessible :mobile_phone, :zipcode

  belongs_to :zipcode

  validates :mobile_phone, :presence => true, :uniqueness => true, :length => { :maximum => 15 }
  validates :zipcode_id, :presence => true
end
