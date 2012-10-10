class StubbedMoon < Moon

  def initialize(phase)
    @phase = phase
  end

  def phase(time)
    @phase
  end

end
