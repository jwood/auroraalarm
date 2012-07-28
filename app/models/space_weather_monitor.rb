class SpaceWeatherMonitor

  def alert_users_of_solar_event
    solar_event = fetch_solar_event
    if solar_event
      alert_users(solar_event)
    end
  end

  private
  
  def fetch_solar_event
    today = DateTime.now.utc.to_date
    yesterday = today - 1.day

    yesterdays_old_event = SolarEvent.occurred_on(yesterday)
    yesterdays_event = strongest_solar_event(yesterday)
    todays_event = strongest_solar_event(today)

    persist_events(yesterdays_old_event, yesterdays_event, todays_event)
    event_to_alert_on(yesterdays_old_event, yesterdays_event, todays_event)
  end

  def strongest_solar_event(date)
    service = SpaceWeatherAlertService.new(date.year, date.month)
    service.strongest_geomagnetic_storm(date)
  end

  def persist_events(yesterdays_old_event, yesterdays_event, todays_event)
    if yesterdays_old_event.nil?
      persist_solar_event(yesterdays_event)
    else
      if yesterdays_old_event.expected_storm_strength < yesterdays_event.geomagnetic_storm_level
        SolarEvent.transaction do
          yesterdays_old_event.destroy
          persist_solar_event(yesterdays_event)
        end
      end
    end

    persist_solar_event(todays_event)
  end

  def event_to_alert_on(yesterdays_old_event, yesterdays_event, todays_event)
    yesterday_old = yesterdays_old_event ? yesterdays_old_event.expected_storm_strength : ""
    yesterday = yesterdays_event ? yesterdays_event.geomagnetic_storm_level : ""
    today = todays_event ? todays_event.geomagnetic_storm_level : ""

    if !yesterday.blank? && !today.blank?
      today > yesterday ? todays_event : yesterdays_event
    elsif !today.blank?
      todays_event
    elsif !yesterday_old.blank? && yesterday > yesterday_old
      yesterdays_event
    else
      nil
    end
  end

  def persist_solar_event(new_event)
    if new_event
      SolarEvent.create!(
        :message_code => new_event.message_code,
        :serial_number => new_event.serial_number,
        :issue_time => new_event.issue_time,
        :expected_storm_strength => new_event.geomagnetic_storm_level)
    end
  end

  def alert_users(solar_event)
    sms_messaging_service = SmsMessagingService.new
    message = OutgoingSmsMessages.storm_prompt(GeomagneticStorm.new(solar_event.geomagnetic_storm_level))
    User.confirmed.find_each do |user|
      create_alert_permission(user)
      sms_messaging_service.send_message(user.mobile_phone, message)
    end
  end

  def create_alert_permission(user)
    AlertPermission.transaction do
      user.unapproved_alert_permission.destroy if user.unapproved_alert_permission
      AlertPermission.create!(:user => user)
    end
  end

end
