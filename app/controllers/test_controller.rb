class TestController < ApplicationController
  http_basic_authenticate_with :name => ENV['PRIVATE_CONTROLLER_USERNAME'], :password => ENV['PRIVATE_CONTROLLER_PASSWORD']

  layout false

  def index
  end

  def alert_users_of_solar_event
    @date = params[:date]

    if @date.blank?
      flash[:notice] = "Date is required"
    else
      sms_messaging_service = StubbedSmsMessagingService.new
      monitor = SpaceWeatherMonitor.new(:date => Date.parse(@date))
      monitor.sms_messaging_service = sms_messaging_service
      monitor.alert_users_of_solar_event
      @sent_messages = sms_messaging_service.sent_messages
    end

    render :action => :index
  end

  def alert_users_of_aurora
    redirect_to test_path
  end

  def send_message
    redirect_to test_path
  end

end
