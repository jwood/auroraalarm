module BelongsToUser
  extend ActiveSupport::Concern

  included do
    belongs_to :user
    scope :for_user, lambda { |user| where(:user_id => user) }
  end

  module ClassMethods
    def distinct_user_ids
      select(:user_id).uniq.map(&:user_id)
    end
  end
end
