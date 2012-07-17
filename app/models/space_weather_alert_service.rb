require 'net/http'

class SpaceWeatherAlertService

  def initialize(year, month)
    @year = year
    @month = month
  end

  def strongest_geomagnetic_storm(date)
    fetch_report
    events = @report.find_events(:date => date, :event_type => :watch)
    events.map { |event| event.geomagnetic_storm_level }.sort.reverse.first
  end

  private

  def fetch_report
    if @report.nil?
      uri = URI.parse("http://www.swpc.noaa.gov/alerts/archive/#{report_name}.html")
      http = Net::HTTP.new(uri.host, uri.port) 
      http.open_timeout = 3
      http.read_timeout = 3
      response = http.request(Net::HTTP::Get.new(uri.request_uri))
      @report = SpaceWeatherAlertReport.new(response.body)
    end
    @report
  end

  def report_name
    "alerts_#{Date.new(@year, @month, 1).strftime("%b%Y")}"
  end

end
