class IncomingSmsMessagesController < ApplicationController

  def index
    @mobile_phone = params[:mobile_phone]
    @message = (params[:message] && params[:message].strip)
    @keyword = (params[:keyword] && params[:keyword].strip)
    @sms_messaging_service = SmsMessagingService.new

    @user = User.find_by_mobile_phone(@mobile_phone)
    if @user
      if signup_confirmation?
        handle_signup_confirmation
      end
    else
      Rails.logger.error "No user could be found with a mobile phone of #{@mobile_phone}"
    end

    render :nothing => true
  end

  private

  def signup_confirmation?
    positive_response?(@message) && !@user.confirmed?
  end

  def handle_signup_confirmation
    @user.update_attribute(:confirmed_at, Time.now)
    @sms_messaging_service.send_message(@user.mobile_phone, OutgoingSmsMessages.signup_confirmation)
  end

  def positive_response?(message)
    ["Y", "YES", "SURE", "OK", "YEP", "CONFIRM"].include?(message.upcase)
  end

end
