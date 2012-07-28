class KnownUserHandler < MessageHandler

  def handle
    if @user
      if signup_confirmation?
        handle_signup_confirmation
        return true
      elsif opt_in_via_sms?
        update_location_for_confirmed_user
        return true
      else
        handle_already_signed_up
        return true
      end
    end
    false
  end

  private

  def signup_confirmation?
    positive_response? && !@user.confirmed?
  end

  def handle_signup_confirmation
    @user.confirmed_at = Time.now
    @user.save
    @sms_messaging_service.send_message(@mobile_phone, OutgoingSmsMessages.signup_confirmation)
  end

  def positive_response?
    ["Y", "YES", "SURE", "OK", "YEP", "CONFIRM"].include?(@message.upcase)
  end

  def update_location_for_confirmed_user
    @message.upcase =~ opt_in_message_regexp
    service = GeolocationService.new
    location = service.geocode($1)

    if location.nil? || location.invalid?
      @sms_messaging_service.send_message(@mobile_phone, OutgoingSmsMessages.bad_location_at_signup)
    elsif location.international?
      @sms_messaging_service.send_message(@mobile_phone, OutgoingSmsMessages.international_location)
    else
      @user.user_location.update_attributes(:city => location.city,
                                            :state => location.state,
                                            :postal_code => location.zip,
                                            :country => location.country_code,
                                            :latitude => location.latitude,
                                            :longitude => location.longitude,
                                            :magnetic_latitude => location.magnetic_latitude)
      @sms_messaging_service.send_message(@mobile_phone, OutgoingSmsMessages.location_update(location.zip))
    end
  end

  def handle_already_signed_up
    @sms_messaging_service.send_message(@mobile_phone, OutgoingSmsMessages.already_signed_up)
  end

end
