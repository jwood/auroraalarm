class CronController < PrivateController

  def alert_users_of_solar_event
    Proby.monitor(ENV['PROBY_ALERT_USERS_OF_SOLAR_EVENT']) do
      SpaceWeatherMonitor.delay.alert_users_of_solar_event
      render nothing: true
    end
  end

  def alert_users_of_aurora
    Proby.monitor(ENV['PROBY_ALERT_USERS_OF_AURORA']) do
      AuroraConditionsMonitor.delay.alert_users_of_aurora_if_conditions_optimal
      render nothing: true
    end
  end

  def cleanup
    Proby.monitor(ENV['PROBY_CLEANUP']) do
      MessageHistory.purge_old_messages
      AuroraAlert.purge_old_alerts
      render nothing: true
    end
  end

end
