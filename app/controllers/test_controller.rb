class TestController < PrivateController

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
      IncomingSmsHandler.process(@mobile_phone, @message, sms_messaging_service)
      @sent_messages = sms_messaging_service.sent_messages
    end

    render :action => :index
  end

  def status
    @user = User.first
    date = Date.today

    @kp_forecast = KpIndexService.new.current_forecast.last
    @cloud_cover_percentage = LocalWeatherService.new.cloud_cover_percentage(@user)
    @latest_space_weather_event = SpaceWeatherAlertService.new(date.year, date.month).report.find_events.first
    @moon_phase = Moon.new.phase(Time.now)
    @nighttime = Nighttime.new.nighttime?(@user)
  end

end
