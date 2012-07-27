class CronController < ApplicationController
  http_basic_authenticate_with :name => ENV['PRIVATE_CONTROLLER_USERNAME'], :password => ENV['PRIVATE_CONTROLLER_PASSWORD']

  def alert_users_of_solar_event
    space_weather_monitor = SpaceWeatherMonitor.new
    space_weather_monitor.alert_users_of_solar_event
    render :nothing => true
  end

end
