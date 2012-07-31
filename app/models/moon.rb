class Moon

  def phase(time)
    p = Moonphase::Moon.new.getphase(time)
    case p
    when "new (totally dark)"                         then :new
    when "waxing crescent (increasing to full)"       then :waxing_crescent
    when "in its first quarter (increasing to full)"  then :first_quarter
    when "waxing gibbous (increasing to full)"        then :waxing_gibbous
    when "full (full light)"                          then :full
    when "waning gibbous (decreasing from full)"      then :waning_gibbous
    when "in its last quarter (decreasing from full)" then :third_quarter
    when "waning crescent (decreasing from full)"     then :waning_crescent
    end
  end

end
