class Zipcode < ActiveRecord::Base
  attr_accessible :code, :latitude, :longitude, :magnetic_latitude

  has_many :users

  validates :code, :presence => true, :uniqueness => true, :length => { :maximum => 5 }, :format => /\d\d\d\d\d/
  validates :latitude, :presence => true, :numericality => true
  validates :longitude, :presence => true, :numericality => true
  validates :magnetic_latitude, :presence => true, :numericality => true

  def self.find_or_create_with_geolocation_data(code)
    return nil if code.blank?

    Zipcode.uncached do
      zipcode = Zipcode.find_by_code(code)
      if zipcode.nil?
        service = GeolocationService.new
        latitude, longitude = service.latitude_and_longitude(code)
        magnetic_latitude = service.magnetic_latitude(code)

        # This may fail due to a race condition, let it.  If we are unable
        # to create the record, we'll attempt to look it up afterwards.
        zipcode = Zipcode.create(:code => code,
                                 :latitude => latitude,
                                 :longitude => longitude,
                                 :magnetic_latitude => magnetic_latitude)
        zipcode = Zipcode.find_by_code(code) unless zipcode.persisted?
      end
      zipcode
    end
  end
end
