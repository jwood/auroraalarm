class AlarmedUserHandler < MessageHandler

  def handle
    if @user && @user.aurora_alert && valid_response?
      if acknowledge_alert?
        update_alert(:confirmed_at => Time.now.utc, :send_reminder_at => nil)
        send_message(OutgoingSmsMessages.acknowledge_alert)
      elsif remind_in_1_hour?
        update_alert(:confirmed_at => Time.now.utc, :send_reminder_at => 1.hour.from_now)
        send_message(OutgoingSmsMessages.remind_at("1 hour"))
      elsif remind_in_2_hours?
        update_alert(:confirmed_at => Time.now.utc, :send_reminder_at => 2.hours.from_now)
        send_message(OutgoingSmsMessages.remind_at("2 hours"))
      elsif no_more_messages_tonight?
        update_alert(:confirmed_at => Time.now.utc, :send_reminder_at => nil)
        send_message(OutgoingSmsMessages.no_more_messages_tonight)
      end
      return true
    end
    return false
  end

  private

  def valid_response?
    acknowledge_alert? || remind_in_1_hour? || remind_in_2_hours? || no_more_messages_tonight?
  end

  def acknowledge_alert?
    ["0", "0)"].include?(@message)
  end

  def remind_in_1_hour?
    ["1", "1)"].include?(@message)
  end

  def remind_in_2_hours?
    ["2", "2)"].include?(@message)
  end

  def no_more_messages_tonight?
    ["3", "3)"].include?(@message)
  end

  def update_alert(attributes)
    @user.aurora_alert.update_attributes(attributes)
  end

  def send_message(message)
    @sms_messaging_service.send_message(@mobile_phone, message)
  end

end
