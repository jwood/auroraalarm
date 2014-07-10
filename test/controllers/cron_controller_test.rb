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
    SpaceWeatherMonitor.expects(:delay).returns(SpaceWeatherMonitor)
    SpaceWeatherMonitor.expects(:alert_users_of_solar_event)
    post :alert_users_of_solar_event
    assert_response :success
  end

  test "should be able to alert users of an aurora" do
    AuroraConditionsMonitor.expects(:delay).returns(AuroraConditionsMonitor)
    AuroraConditionsMonitor.expects(:alert_users_of_aurora_if_conditions_optimal)
    post :alert_users_of_aurora
    assert_response :success
  end

  test "should be able to perform any necessary cleanup" do
    CleanupService.expects(:delay).returns(CleanupService)
    CleanupService.expects(:execute)
    post :cleanup
    assert_response :success
  end

end
