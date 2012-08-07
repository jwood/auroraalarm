class TestController < ApplicationController
  http_basic_authenticate_with :name => ENV['PRIVATE_CONTROLLER_USERNAME'], :password => ENV['PRIVATE_CONTROLLER_PASSWORD']

  layout false

  def index
  end

  def alert_users_of_solar_event
    @date = params[:date]

    if @date.blank?
      flash.now[:notice] = "Date is required"
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
    @kp = params[:kp].blank? ? 0.00 : params[:kp].to_f
    @nighttime = params[:nighttime] == "1"
    @moon_phase = params[:moon_phase].to_sym
    @cloud_cover_percentage = params[:cloud_cover_percentage].blank? ? 0 : params[:cloud_cover_percentage].to_i

    sms_messaging_service = StubbedSmsMessagingService.new
    monitor = AuroraConditionsMonitor.new
    monitor.kp_forecaster = StubbedKpForecaster.new(@kp)
    monitor.nighttime = StubbedNighttime.new(@nighttime)
    monitor.moon = StubbedMoon.new(@moon_phase)
    monitor.local_weather_service = StubbedLocalWeatherService.new(@cloud_cover_percentage)
    monitor.sms_messaging_service = sms_messaging_service
    monitor.alert_users_of_aurora_if_conditions_optimal

    @sent_messages = sms_messaging_service.sent_messages
    render :action => :index
  end

  def send_message
    @mobile_phone = params[:mobile_phone]
    @message = params[:message]

    if @mobile_phone.blank? || @message.blank?
      flash.now[:notice] = "Mobile phone and message are required"
    else
      sms_messaging_service = StubbedSmsMessagingService.new
      IncomingSmsHandler.new(@mobile_phone, @message, "AURORA", sms_messaging_service).process
      @sent_messages = sms_messaging_service.sent_messages
    end

    render :action => :index
  end

end
