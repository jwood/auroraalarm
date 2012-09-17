class IncomingSmsMessagesController < ApplicationController
  http_basic_authenticate_with :name => ENV['SIGNAL_RECEIVE_SMS_USERNAME'], :password => ENV['SIGNAL_RECEIVE_SMS_PASSWORD']

  def index
    mobile_phone = params[:mobile_phone]
    message = (params[:message] && params[:message].strip)

    IncomingSmsHandler.new(mobile_phone, message).process
    render :nothing => true
  end

end
