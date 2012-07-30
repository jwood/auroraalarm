class KpIndexUpdater

  def update_kp_index
    KpIndexService.new.current_forecast.reverse.each do |time, kp_index|
      if KpForecast.exists?(:forecast_time => time)
        break
      else
        KpForecast.create!(:forecast_time => time, :expected_kp => kp_index)
      end
    end
  end

end
