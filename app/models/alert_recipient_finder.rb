class AlertRecipientFinder

  def users
    user_ids = AlertPermission.active.distinct_user_ids - AuroraAlert.do_not_resend.distinct_user_ids
    User.confirmed.where(['id in (?)', user_ids])
  end

end
