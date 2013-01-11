class Nighttime

  def nighttime?(user)
    now = Time.now.utc
    events = solar_events(now, user)

    (0...events.size).each do |i|
      if now >= events[i][0] && now <= events[i+1][0]
        return events[i][1] == :sunset && events[i+1][1] == :sunrise
      end
    end

    false
  end

  private

  def solar_events(now, user)
    today = now.to_date
    latitude = BigDecimal.new(user.user_location.latitude.to_s)
    longitude = BigDecimal.new(user.user_location.longitude.to_s)

    events = []
    events << [SolarEventCalculator.new(today - 1, latitude, longitude).compute_utc_astronomical_sunrise, :sunrise]
    events << [SolarEventCalculator.new(today - 1, latitude, longitude).compute_utc_astronomical_sunset,  :sunset]
    events << [SolarEventCalculator.new(today,     latitude, longitude).compute_utc_astronomical_sunrise, :sunrise]
    events << [SolarEventCalculator.new(today,     latitude, longitude).compute_utc_astronomical_sunset,  :sunset]
    events << [SolarEventCalculator.new(today + 1, latitude, longitude).compute_utc_astronomical_sunrise, :sunrise]
    events << [SolarEventCalculator.new(today + 1, latitude, longitude).compute_utc_astronomical_sunset,  :sunset]
    events.compact.sort!
  end

end
