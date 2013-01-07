module IncomingSmsHandlers
  class AlertedUserHandler < MessageHandler

    def handle
      if @user && @user.unapproved_alert_permission
        return handle_alert_permission_response
      end
      return false
    end

    private

    def handle_alert_permission_response
      if positive_response?
        @user.unapproved_alert_permission.update_attributes(:approved_at => Time.now, :expires_at => 70.hours.from_now)
        @sms_messaging_service.send_message(@mobile_phone, OutgoingSmsMessages.approved_alert_permission)
        return true
      elsif negative_response?
        @user.unapproved_alert_permission.destroy
        @sms_messaging_service.send_message(@mobile_phone, OutgoingSmsMessages.declined_alert_permission)
        return true
      end
      false
    end

  end
end
