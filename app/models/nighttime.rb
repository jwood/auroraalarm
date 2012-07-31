class Nighttime

  def nighttime?(user)
    offset = 2.hours

    now = Time.now.utc
    today = now.to_date
    latitude = BigDecimal.new(user.user_location.latitude.to_s)
    longitude = BigDecimal.new(user.user_location.longitude.to_s)

    yesterday_sunrise = SolarEventCalculator.new(today - 1, latitude, longitude).compute_utc_official_sunrise
    yesterday_sunset  = SolarEventCalculator.new(today - 1, latitude, longitude).compute_utc_official_sunset
    today_sunrise     = SolarEventCalculator.new(today,     latitude, longitude).compute_utc_official_sunrise
    today_sunset      = SolarEventCalculator.new(today,     latitude, longitude).compute_utc_official_sunset
    tomorrow_sunrise  = SolarEventCalculator.new(today + 1, latitude, longitude).compute_utc_official_sunrise
    tomorrow_sunset   = SolarEventCalculator.new(today + 1, latitude, longitude).compute_utc_official_sunset

    events = []
    events << [yesterday_sunrise - offset, :sunrise] if yesterday_sunrise
    events << [yesterday_sunset  + offset, :sunset]  if yesterday_sunset
    events << [today_sunrise     - offset, :sunrise] if today_sunrise
    events << [today_sunset      + offset, :sunset]  if today_sunset
    events << [tomorrow_sunrise  - offset, :sunrise] if tomorrow_sunrise
    events << [tomorrow_sunset   + offset, :sunset]  if tomorrow_sunset
    events.sort!

    (0...events.size).each do |i|
      if now >= events[i][0] && now <= events[i+1][0]
        if events[i][1] == :sunset && events[i+1][1] == :sunrise
          return true
        else
          return false
        end
      end
    end

    false
  end

end
