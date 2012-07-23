class UserFactory
  attr_accessor :errors

  def create_user(mobile_phone, location_value)
    @errors = []

    ensure_valid_phone(mobile_phone)
    ensure_user_does_not_exist(mobile_phone)
    location = lookup_location_data(location_value)

    user = User.new(:mobile_phone => mobile_phone, :user_location_value => location_value)
    if @errors.blank?
      begin
        User.transaction do
          user.save!
          user_location = UserLocation.create!(:user_id => user.id,
                                               :city => location.city,
                                               :state => location.state,
                                               :postal_code => location.zip,
                                               :country => location.country_code,
                                               :latitude => location.latitude,
                                               :longitude => location.longitude,
                                               :magnetic_latitude => location.magnetic_latitude)
        end
      rescue Exception => e
        @errors << "An unexpected error occurred while trying to create a new user"
        Rails.logger.error "An unexpected error occurred when trying to create a new user : #{e.message}"
      end
    end
    user
  end

  private

  def ensure_valid_phone(mobile_phone)
    if !SignalApi::Phone.valid?(mobile_phone)
      @errors << "Mobile phone is invalid"
    end
  end

  def ensure_user_does_not_exist(mobile_phone)
    if User.exists?(:mobile_phone => mobile_phone)
      @errors << "A user with the specified mobile phone already exists"
    end
  end

  def lookup_location_data(location_value)
    service = GeolocationService.new
    location = service.geocode(location_value)

    if location.nil? || location.latitude.blank? || location.longitude.blank?
      @errors << "Location is invalid"
      nil
    else
      location
    end
  end

end
