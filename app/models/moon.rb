class Moon

  def phase(time)
    p = Moonphase::Moon.new.getphase(time)
    Moon.phases[p]
  end

  def self.phases
    {
      "new (totally dark)"                         => :new,
      "waxing crescent (increasing to full)"       => :waxing_crescent,
      "in its first quarter (increasing to full)"  => :first_quarter,
      "waxing gibbous (increasing to full)"        => :waxing_gibbous,
      "full (full light)"                          => :full,
      "waning gibbous (decreasing from full)"      => :waning_gibbous,
      "in its last quarter (decreasing from full)" => :third_quarter,
      "waning crescent (decreasing from full)"     => :waning_crescent
    }
  end

  def dark?(time)
    if Aurora::Application.config.consider_moonlight
      [:new, :waxing_crescent, :first_quarter, :third_quarter, :waning_crescent].include?(phase(time))
    else
      true
    end
  end

end
