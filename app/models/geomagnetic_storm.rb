class GeomagneticStorm
  attr_reader :scale, :description, :kp_level

  def initialize(scale, description, kp_level)
    @scale = scale
    @description = description
    @kp_level = kp_level
  end

  def self.build(scale)
    "GeomagneticStorm::#{scale}".constantize.new(scale)
  rescue NameError
    nil
  end

  class G1 < GeomagneticStorm
    def initialize(scale)
      super(scale, "minor", 5)
    end
  end

  class G2 < GeomagneticStorm
    def initialize(scale)
      super(scale, "moderate", 6)
    end
  end

  class G3 < GeomagneticStorm
    def initialize(scale)
      super(scale, "strong", 7)
    end
  end

  class G4 < GeomagneticStorm
    def initialize(scale)
      super(scale, "severe", 8)
    end
  end

  class G5 < GeomagneticStorm
    def initialize(scale)
      super(scale, "extreme", 9)
    end
  end

end
