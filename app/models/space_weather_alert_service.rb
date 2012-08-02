require 'net/http'

class SpaceWeatherAlertService
  include HttpGetter

  def initialize(year, month)
    @year = year
    @month = month
  end

  def strongest_geomagnetic_storm(date)
    fetch_report
    if @report
      events = @report.find_events(:date => date, :event_type => :watch)
      events.sort { |a,b| [a.geomagnetic_storm_level, a.issue_time] <=> [b.geomagnetic_storm_level, b.issue_time] }.reverse.first
    end
  end

  private

  def fetch_report
    if @report.nil?
      data = http_get("http://www.swpc.noaa.gov/alerts/archive/#{report_name}.html")
      if data
        @report = SpaceWeatherAlertReport.new(data)
      end
    end
    @report
  end

  def report_name
    "alerts_#{Date.new(@year, @month, 1).strftime("%b%Y")}"
  end

end
