class UnknownUserHandler < MessageHandler

  def handle
    if @user.nil?
      if opt_in_via_sms_missing_location?
        handle_opt_in_via_sms_missing_location
        return true
      elsif opt_in_via_sms?
        handle_opt_in_via_sms
        return true
      end
    end
    false
  end

  private

  def opt_in_via_sms_missing_location?
    ["AURORA", "START"].include?(@message.upcase)
  end

  def handle_opt_in_via_sms_missing_location
    @sms_messaging_service.send_message(@mobile_phone, OutgoingSmsMessages.location_prompt)
  end

  def handle_opt_in_via_sms
    factory = UserFactory.new
    @message.upcase =~ opt_in_message_regexp
    @user = factory.create_user(@mobile_phone, ($1 || "").strip)
    @errors = factory.errors

    if @errors.blank?
      response_message = OutgoingSmsMessages.signup_confirmation
      @user.update_attributes(confirmed_at: Time.now)
    elsif factory.location && factory.location.international?
      response_message = OutgoingSmsMessages.international_location
    else
      response_message = OutgoingSmsMessages.bad_location_at_signup
    end
    @sms_messaging_service.send_message(@mobile_phone, response_message)
  end

end
