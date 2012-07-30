require 'net/http'

class KpIndexService
  include HttpGetter

  def current_forecast
    forecast = []
    data = forecast_data || ""
    data.split("\n").each do |line|
      unless line =~ /^[#:]/
        line_data = line.split(/\s+/)
        forecast_time = Time.parse("#{line_data[5]}#{line_data[6]}#{line_data[7]} #{line_data[8][0..1]}:#{line_data[8][2..3]} UTC")
        forecast_kp = line_data[9].to_f
        forecast << [forecast_time, forecast_kp]
      end
    end
    forecast
  end

  private

  def forecast_data
    @data ||= http_get("http://www.swpc.noaa.gov/wingkp/wingkp_list.txt")
  end

end
