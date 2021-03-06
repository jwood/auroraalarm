class SpaceWeatherMonitor
  attr_accessor :sms_messaging_service

  def initialize(params={})
    @today = params[:date] || DateTime.now.utc.to_date
    @moon = params[:moon] || Moon.new
    @yesterday = @today - 1.day
    @sms_messaging_service = SmsMessagingService.new
  end

  def alert_users_of_solar_event
    clear_expired_alert_permissions
    solar_event = fetch_solar_event
    if solar_event && moon_will_be_dark(solar_event)
      alert_users(solar_event)
    end
  end

  def self.alert_users_of_solar_event
    self.new.alert_users_of_solar_event
  end

  private

  def clear_expired_alert_permissions
    AlertPermission.expired.destroy_all
  end

  def fetch_solar_event
    yesterdays_old_event = SolarEvent.occurred_on(@yesterday)
    yesterdays_event = strongest_solar_event(@yesterday)
    todays_event = strongest_solar_event(@today)

    persist_events(yesterdays_old_event, yesterdays_event, todays_event)
    event_to_alert_on(yesterdays_old_event, yesterdays_event, todays_event)
  end

  def strongest_solar_event(date)
    service = SpaceWeatherAlertService.new
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
    elsif yesterday_old.blank? && !yesterday.blank? && today.blank?
      yesterdays_event
    else
      nil
    end
  end

  def persist_solar_event(new_event)
    if new_event
      SolarEvent.create(
        message_code: new_event.message_code,
        serial_number: new_event.serial_number,
        issue_time: new_event.issue_time,
        expected_storm_strength: new_event.geomagnetic_storm_level)
    end
  end

  def moon_will_be_dark(solar_event)
    @moon.dark?(solar_event.issue_time + 1.day) ||
      @moon.dark?(solar_event.issue_time + 2.days) ||
      @moon.dark?(solar_event.issue_time + 3.days)
  end

  def alert_users(solar_event)
    geomagnetic_storm = GeomagneticStorm.build(solar_event.geomagnetic_storm_level)
    kp_value = KpValue.new(geomagnetic_storm.kp_level + 1)
    message = OutgoingSmsMessages.storm_prompt(geomagnetic_storm)

    User.confirmed.find_each do |user|
      if kp_value.aurora_viewable_at_geomagnetic_latitude?(user.user_location.magnetic_latitude)
        create_alert_permission(user)
        sms_messaging_service.send_message(user.mobile_phone, message)
      end
    end
  end

  def create_alert_permission(user)
    AlertPermission.transaction do
      user.unapproved_alert_permission.destroy if user.unapproved_alert_permission
      AlertPermission.create!(user: user)
    end
  end

end
