class StubbedKpForecaster

  def initialize(kp_level)
    @kp_level = kp_level
  end

  def current_kp_forecast
    KpForecast.new(:forecast_time => Time.now.utc, :expected_kp => @kp_level)
  end

end
