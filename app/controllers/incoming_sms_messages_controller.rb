class IncomingSmsMessagesController < ApplicationController

  def index
    @mobile_phone = params[:mobile_phone]
    @message = (params[:message] && params[:message].strip)
    @keyword = (params[:keyword] && params[:keyword].strip)
    @sms_messaging_service = SmsMessagingService.new

    @user = User.find_by_mobile_phone(@mobile_phone)
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
      end
    end

    render :nothing => true
  end

  private

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
    @message.upcase =~ opt_in_message_regexp
    zipcode = Zipcode.find_or_create_with_geolocation_data(($1 || "").strip)
    @user = User.new(:mobile_phone => @mobile_phone, :zipcode => zipcode)

    if @user.save
      response_message = OutgoingSmsMessages.signup_confirmation
    else
      response_message = OutgoingSmsMessages.bad_location_at_signup
    end
    @sms_messaging_service.send_message(@mobile_phone, response_message)
  end

  def opt_in_message_regexp
    @opt_in_message_regexp ||= Regexp.new("^AURORA\s+([^\s]+)$", Regexp::IGNORECASE)
  end

end