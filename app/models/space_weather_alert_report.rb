class SpaceWeatherAlertReport

  class SpaceWeatherEvent
    attr_reader :event_type, :message_code, :serial_number, :issue_time, :kp_index, :geomagnetic_storm_level

    def initialize(message_code, serial_number, issue_time, kp_index, geomagnetic_storm_level)
      @message_code = message_code
      @event_type = determine_event_type(message_code)
      @serial_number = serial_number
      @issue_time = Time.parse(issue_time)
      @kp_index = kp_index.to_i
      @geomagnetic_storm_level = geomagnetic_storm_level
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
  end


  attr_reader :events

  def initialize(html_report)
    @events = []
    parse_report(html_report)
  end

  def find_events(options={})
    events = @events
    events = find_events_by_date(events, options[:date]) if options[:date]
    events = find_events_by_event_type(events, options[:event_type]) if options[:event_type]
    events
  end

  private

  def find_events_by_date(events, date)
    events.select { |e| e.issue_time.to_date == date }
  end

  def find_events_by_event_type(events, event_type)
    events.select { |e| e.event_type == event_type }
  end

  def parse_report(html_report)
    section = []
    processing_section = false

    html_report.each_line do |line|
      if processing_section && line.blank?
        @events << parse_section(section)
        section = []
        processing_section = false
      end

      if processing_section
        section << line
      end

      if line =~ /<hr><p>/
        processing_section = true
      end
    end
  end

  def parse_section(section)
    message_code = serial_number = issue_time = kp_index = geomagnetic_storm_level = nil
    section.each do |line|
      message_code = $1 if line =~ /^Space Weather Message Code: (.*)<br>/
      serial_number = $1 if line =~ /^Serial Number: (.*)<br>/
      issue_time = "#{$1} #{$2} #{$3[0..1]}:#{$3[2..3]} #{$4}" if line =~ /^Issue Time: (\d\d\d\d) (.*) (\d\d\d\d) (.*)<br>/
      kp_index = $1 if line =~ /Geomagnetic K-index of (\d+).*<br>/
      geomagnetic_storm_level = "G#{$1}" if line =~ /^NOAA Scale: Periods reaching the G(\d) .* Level Likely/
    end
    SpaceWeatherEvent.new(message_code, serial_number, issue_time, kp_index, geomagnetic_storm_level)
  end

end
