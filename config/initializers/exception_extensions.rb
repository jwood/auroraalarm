class Exception
  def message_with_backtrace
    pretty_message = "#{self.class.name}: #{message}"
    if backtrace
      "#{pretty_message}\n#{Rails.backtrace_cleaner.clean(backtrace).join("\n")}"
    else
      pretty_message
    end
  end
end

