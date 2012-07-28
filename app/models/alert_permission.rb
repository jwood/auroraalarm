class AlertPermission < ActiveRecord::Base
  attr_accessible :user, :approved_at, :expires_at

  validates :user_id, :presence => true, :uniqueness => true

  belongs_to :user
end
