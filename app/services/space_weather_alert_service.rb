require 'net/http'

class SpaceWeatherAlertService
  include HttpGetter

  def strongest_geomagnetic_storm(date)
    if events
      filtered_events = events.find_all { |e| e.issue_time.to_date == date && e.event_type == :watch }
      filtered_events.sort { |a,b| [a.geomagnetic_storm_level, a.issue_time] <=> [b.geomagnetic_storm_level, b.issue_time] }.reverse.first
    end
  end

  def events
    @events ||= fetch_events
  end

  def self.data_url
    "http://services.swpc.noaa.gov/products/alerts.json"
  end

  private

  def fetch_events
    json = http_get(SpaceWeatherAlertService.data_url)
    if json
      alerts = JSON.parse(json)
      alerts.map { |alert| SpaceWeatherEvent.new(alert) }
    end
  end

end
