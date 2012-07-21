class IncomingSmsMessagesController < ApplicationController

  def index
    @mobile_phone = params[:mobile_phone]
    @message = (params[:message] && params[:message].strip)
    @keyword = (params[:keyword] && params[:keyword].strip)
    @sms_messaging_service = SmsMessagingService.new

    @user = User.find_by_mobile_phone(@mobile_phone)
    if @user.nil?
      if opt_in_via_sms?
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

  def opt_in_via_sms?
    @message.upcase == "AURORA" && @keyword.upcase == "AURORA"
  end

  def handle_opt_in_via_sms
    @sms_messaging_service.send_message(@mobile_phone, OutgoingSmsMessages.zipcode_prompt)
  end

end
