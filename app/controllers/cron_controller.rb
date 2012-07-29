class CronController < ApplicationController
  http_basic_authenticate_with :name => ENV['PRIVATE_CONTROLLER_USERNAME'], :password => ENV['PRIVATE_CONTROLLER_PASSWORD']

  def alert_users_of_solar_event
    Proby.monitor(ENV['PROBY_ALERT_USERS_OF_SOLAR_EVENT']) do
      SpaceWeatherMonitor.new.alert_users_of_solar_event
      render :nothing => true
    end
  end

end
