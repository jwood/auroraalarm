class KpIndexUpdater

  def update_kp_index
    remove_old_data
    KpIndexService.new.current_forecast.reverse.each do |time, kp_index|
      if time.year != -1 # Kp index service will sometimes contain invalid data
        if KpForecast.exists?(:forecast_time => time)
          break
        else
          KpForecast.create!(:forecast_time => time, :expected_kp => kp_index)
        end
      end
    end
  end

  private

  def remove_old_data
    KpForecast.old.destroy_all
  end

end
