class GeomagneticStorm
  attr_reader :scale

  def initialize(scale)
    @scale = scale
  end

  def description
    case @scale
    when "G1" then "minor"
    when "G2" then "moderate"
    when "G3" then "strong"
    when "G4" then "severe"
    when "G5" then "extreme"
    end
  end

end
