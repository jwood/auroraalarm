require 'net/http'

class KpIndexService
  include HttpGetter

  def self.current_forecast
    self.new.current_forecast
  end

  def current_forecast
    forecast = []
    data = forecast_data || ""
    data.split("\n").reject(&:blank?).each do |line|
      unless line =~ /^[#:]/
        line_data = line.split(/\s+/)
        forecast_time = Time.parse("#{line_data[5]}#{line_data[6]}#{line_data[7]} #{line_data[8][0..1]}:#{line_data[8][2..3]} UTC")
        forecast_kp = line_data[9].to_f
        forecast << [forecast_time, forecast_kp]
      end
    end
    forecast
  end

  def self.data_url
    "http://services.swpc.noaa.gov/text/wing-kp.txt"
  end

  private

  def forecast_data
    @data ||= http_get(KpIndexService.data_url)
  end

end
