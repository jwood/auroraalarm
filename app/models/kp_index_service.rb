require 'net/http'

class KpIndexService
  include HttpGetter

  def current_forecast
    data = forecast_data
    unless data.blank?
      data = data.split("\n").last.split(/\s+/)
      forecast_date = Time.parse("#{data[5]}#{data[6]}#{data[7]} #{data[8][0..1]}:#{data[8][2..3]} UTC")
      forecast_kp = data[9].to_f
      [forecast_date, forecast_kp]
    end
  end

  private

  def forecast_data
    @data ||= http_get("http://www.swpc.noaa.gov/wingkp/wingkp_list.txt")
  end

end
