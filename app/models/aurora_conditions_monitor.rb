class AuroraConditionsMonitor
  attr_accessor :alert_recipient_finder, :kp_forecaster, :nighttime, :moon

  def initialize
    @alert_recipient_finder = AlertRecipientFinder.new
    @kp_forecaster = KpForecaster.new
    @nighttime = Nighttime.new
    @moon = Moon.new
    @sms_messaging_service = SmsMessagingService.new
  end

  def alert_users_of_aurora_if_conditions_optimal
    current_kp_forecast = kp_forecaster.current_kp_forecast
    if current_kp_forecast && current_kp_forecast.storm_level?
      alert_recipient_finder.users.each do |user|
        if conditions_optimal_for_user(user)
          alert_user(user)
        end
      end
    end
  end

  private

  def conditions_optimal_for_user(user)
    aurora_viewable_at_magnetic_latitude?(user) && nighttime?(user) && dark_moon? && clear_skies?(user)
  end

  def aurora_viewable_at_magnetic_latitude?(user)
    kp_value = kp_forecaster.current_kp_forecast.expected_kp
    magnetic_latitude = user.user_location.magnetic_latitude

    if kp_value <= 1.0
      magnetic_latitude >= 66.5
    elsif kp_value <= 2.0
      magnetic_latitude >= 64.5
    elsif kp_value <= 3.0
      magnetic_latitude >= 62.4
    elsif kp_value <= 4.0
      magnetic_latitude >= 60.4
    elsif kp_value <= 5.0
      magnetic_latitude >= 58.3
    elsif kp_value <= 6.0
      magnetic_latitude >= 56.3
    elsif kp_value <= 7.0
      magnetic_latitude >= 54.2
    elsif kp_value <= 8.0
      magnetic_latitude >= 52.2
    elsif kp_value <= 9.0
      magnetic_latitude >= 50.1
    elsif kp_value <= 10.0
      magnetic_latitude >= 48.1
    end
  end

  def nighttime?(user)
    @nighttime.nighttime?(user)
  end

  def dark_moon?
    [:new, :waxing_crescent, :first_quarter, :third_quarter, :waning_crescent].include?(@moon.phase(Time.now.utc))
  end

  def clear_skies?(user)
    # TODO
    true
  end

  def alert_user(user)
    @sms_messaging_service.send_message(user.mobile_phone, OutgoingSmsMessages.aurora_alert)
  end

end
