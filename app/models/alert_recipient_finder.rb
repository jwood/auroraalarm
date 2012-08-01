class AlertRecipientFinder

  def users
    User.confirmed.where(['id in (?)', AlertPermission.active.distinct_user_ids])
  end

end
