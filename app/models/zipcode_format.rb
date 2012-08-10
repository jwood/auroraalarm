class ZipcodeFormat

  def self.valid?(zipcode)
    zipcode && zipcode.to_s.strip =~ valid_format
  end

  def self.valid_format
    /^\d\d\d\d\d$/
  end

end
