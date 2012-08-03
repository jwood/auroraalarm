class IncomingSmsMessagesController < ApplicationController
  http_basic_authenticate_with :name => ENV['SIGNAL_RECEIVE_SMS_USERNAME'], :password => ENV['SIGNAL_RECEIVE_SMS_PASSWORD']

  def index
    mobile_phone = params[:mobile_phone]
    message = (params[:message] && params[:message].strip)
    keyword = (params[:keyword] && params[:keyword].strip)

    MessageHistory.create(:mobile_phone => mobile_phone, :message => message, :message_type => "MO")
    user = User.find_by_mobile_phone(mobile_phone)

    handlers = [
      StopMessageHandler.new(mobile_phone, message, keyword, user),
      UnknownUserHandler.new(mobile_phone, message, keyword, user),
      AlertedUserHandler.new(mobile_phone, message, keyword, user),
      AlarmedUserHandler.new(mobile_phone, message, keyword, user),
      KnownUserHandler.new(mobile_phone, message, keyword, user)
    ]

    handled = false
    handlers.each do |handler|
      handled = handler.handle
      break if handled
    end

    Rails.logger.error "Unable to handle message \"#{message}\" from mobile phone #{mobile_phone}" unless handled
    render :nothing => true
  end

end
