class KpValue
  attr_reader :kp_value

  def initialize(kp_value)
    @kp_value = kp_value
  end

  def aurora_viewable_at_geomagnetic_latitude?(geomagnetic_latitude)
    if @kp_value <= 0.9999
      geomagnetic_latitude >= 66.5
    elsif @kp_value <= 1.9999
      geomagnetic_latitude >= 64.5
    elsif @kp_value <= 2.9999
      geomagnetic_latitude >= 62.4
    elsif @kp_value <= 3.9999
      geomagnetic_latitude >= 60.4
    elsif @kp_value <= 4.9999
      geomagnetic_latitude >= 58.3
    elsif @kp_value <= 5.9999
      geomagnetic_latitude >= 56.3
    elsif @kp_value <= 6.9999
      geomagnetic_latitude >= 54.2
    elsif @kp_value <= 7.9999
      geomagnetic_latitude >= 52.2
    elsif @kp_value <= 8.9999
      geomagnetic_latitude >= 50.1
    elsif @kp_value <= 10
      geomagnetic_latitude >= 48.1
    end
  end

end
