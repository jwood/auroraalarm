class SpaceWeatherAlertReport
  class SpaceWeatherEvent
    attr_reader :message_code, :serial_number, :issue_time, :expected_kp_index

    def initialize(message_code, serial_number, issue_time, expected_kp_index)
      @message_code = message_code
      @serial_number = serial_number
      @issue_time = Time.parse(issue_time)
      @expected_kp_index = expected_kp_index.to_i
    end
  end

  attr_reader :events

  def initialize(html_report)
    @events = []
    parse_report(html_report)
  end

  private

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
    message_code = serial_number = issue_time = expected_kp_index = nil
    section.each do |line|
      message_code = $1 if line =~ /^Space Weather Message Code: (.*)<br>/
      serial_number = $1 if line =~ /^Serial Number: (.*)<br>/
      issue_time = "#{$1} #{$2} #{$3[0..1]}:#{$3[2..3]} #{$4}" if line =~ /^Issue Time: (\d\d\d\d) (.*) (\d\d\d\d) (.*)<br>/
      expected_kp_index = $1 if line =~ /Geomagnetic K-index of (.*) expected<br>/
    end
    SpaceWeatherEvent.new(message_code, serial_number, issue_time, expected_kp_index)
  end

end
