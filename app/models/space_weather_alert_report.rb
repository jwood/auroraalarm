class SpaceWeatherAlertReport

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
    message_code = serial_number = issue_time = kp_index = nil
    section.each do |line|
      message_code = $1 if line =~ /^Space Weather Message Code: (.*)<br>/
      serial_number = $1 if line =~ /^Serial Number: (.*)<br>/
      issue_time = "#{$1} #{$2} #{$3[0..1]}:#{$3[2..3]} #{$4}" if line =~ /^Issue Time: (\d\d\d\d) (.*) (\d\d\d\d) (.*)<br>/
      kp_index = $1 if line =~ /Geomagnetic K-index of (\d+).*<br>/
    end
    SpaceWeatherEvent.new(message_code, serial_number, issue_time, kp_index, nil)
  end

end
