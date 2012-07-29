require 'test_helper'

class CronControllerTest < ActionController::TestCase

  def setup
    @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV['PRIVATE_CONTROLLER_USERNAME'], ENV['PRIVATE_CONTROLLER_PASSWORD'])
  end

  test "should deny access if credentials are incorrect" do
    @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('foo', 'bar')
    post :alert_users_of_solar_event
    assert_response :unauthorized
  end

  test "should be able to alert users of solar events" do
    SmsMessagingService.any_instance.expects(:send_message).times(2).with() { |mobile_phone, message| message == OutgoingSmsMessages.storm_prompt(GeomagneticStorm.new("G3")) }
    SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(Date.yesterday).returns(solar_event("G3", DateTime.now.utc - 1.day))
    SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(Date.today).returns(solar_event("G2", DateTime.now.utc))
    assert_difference 'SolarEvent.count', 2 do
      post :alert_users_of_solar_event
    end
  end

end