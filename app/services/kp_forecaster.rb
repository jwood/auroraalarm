class KpForecaster

  def initialize
    KpIndexUpdater.update_kp_index
  end

  def current_kp_forecast
    @kp_forecast ||= KpForecast.current
  end

end
