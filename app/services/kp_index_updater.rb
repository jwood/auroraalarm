class KpIndexUpdater

  def self.update_kp_index
    self.new.update_kp_index
  end

  def update_kp_index
    remove_old_data
    KpIndexService.current_forecast.reverse.each do |time, kp_index|
      if time.year != -1 # Kp index service will sometimes contain invalid data
        if KpForecast.exists?(forecast_time: time)
          break
        else
          KpForecast.create!(forecast_time: time, expected_kp: kp_index)
        end
      end
    end
  end

  private

  def remove_old_data
    KpForecast.old.destroy_all
  end

end
