class AuroraConditionsMonitor
  attr_accessor :alert_recipient_finder, :kp_forecaster, :nighttime, :moon, :local_weather_service, :sms_messaging_service

  def initialize
    @alert_recipient_finder = AlertRecipientFinder.new
    @kp_forecaster = KpForecaster.new
    @nighttime = Nighttime.new
    @moon = Moon.new
    @local_weather_service = LocalWeatherService.new
    @sms_messaging_service = SmsMessagingService.new
  end

  def alert_users_of_aurora_if_conditions_optimal
    Proby.monitor(ENV['PROBY_ALERT_USERS_OF_AURORA']) do
      current_kp_forecast = kp_forecaster.current_kp_forecast
      if current_kp_forecast && current_kp_forecast.storm_level?
        alert_recipient_finder.users.each do |user|
          if conditions_optimal_for_user(user)
            alert_user(user)
          end
        end
      end
    end
  end

  def self.alert_users_of_aurora_if_conditions_optimal
    self.new.alert_users_of_aurora_if_conditions_optimal
  end

  private

  def conditions_optimal_for_user(user)
    aurora_viewable_at_magnetic_latitude?(user) && nighttime?(user) && dark_moon? && clear_skies?(user)
  end

  def aurora_viewable_at_magnetic_latitude?(user)
    kp_value = kp_forecaster.current_kp_forecast.expected_kp
    magnetic_latitude = user.user_location.magnetic_latitude
    KpValue.new(kp_value).aurora_viewable_at_geomagnetic_latitude?(magnetic_latitude)
  end

  def nighttime?(user)
    @nighttime.nighttime?(user)
  end

  def dark_moon?
    @moon.dark?(Time.now.utc)
  end

  def clear_skies?(user)
    cloud_cover_percentage = @local_weather_service.cloud_cover_percentage(user)
    cloud_cover_percentage && cloud_cover_percentage <= 20
  end

  def alert_user(user)
    aurora_alert = user.aurora_alert
    if aurora_alert.blank?
      AuroraAlert.create(user: user)
    else
      aurora_alert.mark_as_resent
    end

    @sms_messaging_service.send_message(user.mobile_phone, OutgoingSmsMessages.aurora_alert)
  end

end
