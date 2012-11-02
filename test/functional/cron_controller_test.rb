require 'test_helper'

class CronControllerTest < ActionController::TestCase

  def setup
    @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV['PRIVATE_CONTROLLER_USERNAME'], ENV['PRIVATE_CONTROLLER_PASSWORD'])
    @yesterday= (DateTime.now.utc - 1.day).to_date
    @today= DateTime.now.utc.to_date
  end

  test "should deny access if credentials are incorrect" do
    @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('foo', 'bar')
    post :alert_users_of_solar_event
    assert_response :unauthorized
  end

  test "should be able to alert users of solar events" do
    Moon.any_instance.expects(:dark?).returns(true)
    SmsMessagingService.any_instance.expects(:send_message).times(2).with() { |mobile_phone, message| message == OutgoingSmsMessages.storm_prompt(GeomagneticStorm.new("G3")) }
    SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(@yesterday).returns(solar_event("G3", DateTime.now.utc - 1.day))
    SpaceWeatherAlertService.any_instance.expects(:strongest_geomagnetic_storm).with(@today).returns(solar_event("G2", DateTime.now.utc))
    assert_difference 'SolarEvent.count', 2 do
      post :alert_users_of_solar_event
    end
    assert_response :success
  end

  test "should be able to alert users of an aurora" do
    FakeWeb.register_uri(:get, "http://www.swpc.noaa.gov/wingkp/wingkp_list.txt", :body => "")
    AuroraConditionsMonitor.any_instance.expects(:alert_users_of_aurora_if_conditions_optimal)
    post :alert_users_of_aurora
    assert_response :success
  end

  test "should be able to perform any necessary cleanup" do
    AuroraAlert.create!(:user => users(:john), :first_sent_at => 12.hours.ago)
    assert_difference 'MessageHistory.count', -2 do
      assert_difference 'AuroraAlert.count', -1 do
        post :cleanup
      end
    end
    assert_response :success
  end

end
