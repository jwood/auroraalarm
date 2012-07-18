require 'net/http'

class SpaceWeatherAlertService
  include HttpGetter

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
      data = http_get("http://www.swpc.noaa.gov/alerts/archive/#{report_name}.html")
      @report = SpaceWeatherAlertReport.new(data)
    end
    @report
  end

  def report_name
    "alerts_#{Date.new(@year, @month, 1).strftime("%b%Y")}"
  end

end