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
      events = @report.find_events(date: date, event_type: :watch)
      events.sort { |a,b| [a.geomagnetic_storm_level, a.issue_time] <=> [b.geomagnetic_storm_level, b.issue_time] }.reverse.first
    end
  end

  def report
    fetch_report
    @report
  end

  def self.data_url(date)
    "http://www.swpc.noaa.gov/alerts/archive/#{report_name(date)}.html"
  end

  private

  def fetch_report
    if @report.nil?
      data = http_get(SpaceWeatherAlertService.data_url(Date.new(@year, @month)))
      if data
        @report = SpaceWeatherAlertReport.new(data)
      end
    end
    @report
  end

  def self.report_name(date)
    "alerts_#{date.strftime("%b%Y")}"
  end

end
