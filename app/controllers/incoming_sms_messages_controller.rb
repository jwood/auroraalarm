class IncomingSmsMessagesController < ApplicationController
  http_basic_authenticate_with :name => ENV['SIGNAL_RECEIVE_SMS_USERNAME'], :password => ENV['SIGNAL_RECEIVE_SMS_PASSWORD']

  def index
    @mobile_phone = params[:mobile_phone]
    @message = (params[:message] && params[:message].strip)
    @keyword = (params[:keyword] && params[:keyword].strip)
    @sms_messaging_service = SmsMessagingService.new

    @user = User.find_by_mobile_phone(@mobile_phone)

    if stop_message?
      handle_stop_message
    else
      if @user.nil?
        if opt_in_via_sms_missing_location?
          handle_opt_in_via_sms_missing_location
        elsif opt_in_via_sms?
          handle_opt_in_via_sms
        else
          Rails.logger.error "No user could be found with a mobile phone of #{@mobile_phone}"
        end
      else
        if signup_confirmation?
          handle_signup_confirmation
        elsif opt_in_via_sms?
          update_location_for_confirmed_user
        else
          handle_already_signed_up
        end
      end
    end

    render :nothing => true
  end

  private

  def stop_message?
    @message.upcase =~ /STOP/
  end

  def handle_stop_message
    @user.destroy if @user
    @sms_messaging_service.send_message(@mobile_phone, OutgoingSmsMessages.stop)
  end

  def signup_confirmation?
    positive_response? && !@user.confirmed?
  end

  def handle_signup_confirmation
    @user.update_attribute(:confirmed_at, Time.now)
    @sms_messaging_service.send_message(@mobile_phone, OutgoingSmsMessages.signup_confirmation)
  end

  def positive_response?
    ["Y", "YES", "SURE", "OK", "YEP", "CONFIRM"].include?(@message.upcase)
  end

  def opt_in_via_sms_missing_location?
    @message.upcase == "AURORA"
  end

  def handle_opt_in_via_sms_missing_location
    @sms_messaging_service.send_message(@mobile_phone, OutgoingSmsMessages.location_prompt)
  end

  def opt_in_via_sms?
    @message.upcase =~ opt_in_message_regexp
  end

  def handle_opt_in_via_sms
    factory = UserFactory.new
    @message.upcase =~ opt_in_message_regexp
    @user = factory.create_user(@mobile_phone, ($1 || "").strip)
    @errors = factory.errors

    if @errors.blank?
      response_message = OutgoingSmsMessages.signup_confirmation
    elsif factory.location && factory.location.international?
      response_message = OutgoingSmsMessages.international_location
    else
      response_message = OutgoingSmsMessages.bad_location_at_signup
    end
    @sms_messaging_service.send_message(@mobile_phone, response_message)
  end

  def opt_in_message_regexp
    @opt_in_message_regexp ||= Regexp.new("^AURORA\s+(.*)$", Regexp::IGNORECASE)
  end

  def handle_already_signed_up
    @sms_messaging_service.send_message(@mobile_phone, OutgoingSmsMessages.already_signed_up)
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

end
