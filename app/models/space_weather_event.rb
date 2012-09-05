class SpaceWeatherEvent
  attr_reader :event_type, :message_code, :serial_number, :issue_time, :kp_index, :geomagnetic_storm_level

  def initialize(message_code, serial_number, issue_time, kp_index=nil, geomagnetic_storm_level=nil)
    @message_code = message_code
    @event_type = determine_event_type(message_code)
    @serial_number = serial_number
    @issue_time = Time.parse(issue_time)
    @kp_index = kp_index.nil? ? determine_kp_index(message_code) : kp_index.to_i
    @geomagnetic_storm_level = geomagnetic_storm_level || determine_geomagnetic_storm_level(message_code) || ""
  end

  private

  def determine_event_type(message_code)
    event_type_code = message_code[0..2]
    case event_type_code
    when "WAT" then :watch
    when "SUM" then :summary
    when "WAR" then :warning
    when "ALT" then :alert
    else :unknown
    end
  end

  def determine_geomagnetic_storm_level(message_code)
    case message_code
    when "WATA20", "WARK05", "ALTK05" then "G1"
    when "WATA30", "WARK06", "ALTK06" then "G2"
    when "WATA50", "WARK07", "ALTK07" then "G3"
    when "WATA99", "ALTK08" then "G4"
    when "ALTK09" then "G5"
    else nil
    end
  end

  def determine_kp_index(message_code)
    case message_code
    when "WARK04", "ALTK04" then 4
    when "WARK05", "ALTK05" then 5
    when "WARK06", "ALTK06" then 6
    when "WARK07", "ALTK07" then 7
    when "ALTK08" then 8
    when "ALTK09" then 9
    else 0
    end
  end

end

