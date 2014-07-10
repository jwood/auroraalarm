class CronController < PrivateController

  def alert_users_of_solar_event
    SpaceWeatherMonitor.delay.alert_users_of_solar_event
    render nothing: true
  end

  def alert_users_of_aurora
    AuroraConditionsMonitor.delay.alert_users_of_aurora_if_conditions_optimal
    render nothing: true
  end

  def cleanup
    CleanupService.delay.execute
    render nothing: true
  end

end
