require 'test_helper'

class SiteControllerTest < ActionController::TestCase

  test "should be able to fetch the index page" do
    get :index
    assert_response :success
    assert_template :index
    assert_not_nil assigns(:user)
  end

  test "should be able to create a new user" do
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with("60477").returns(GeoKit::GeoLoc.new(:lat => 41.5699614, :lng => -87.7861711))
    SmsMessagingService.any_instance.expects(:send_message).with("3125551212", OutgoingSmsMessages.signup_prompt)

    assert_difference 'User.count', 1 do
      assert_difference 'Zipcode.count', 1 do
        post :new_user, :user => { :mobile_phone => "3125551212", :zipcode_value => "60477" }
      end
    end

    assert_response :success
    assert_template :new_user

    zipcode = Zipcode.last
    assert_equal "60477", zipcode.code
    assert_equal 41.5699614, zipcode.latitude
    assert_equal -87.7861711, zipcode.longitude
    assert_equal 52, zipcode.magnetic_latitude

    user = User.last
    assert_equal zipcode, user.zipcode
    assert_equal "3125551212", user.mobile_phone
  end

  test "should not be able to create a user without a zip code" do
    assert_no_difference 'User.count' do
      assert_no_difference 'Zipcode.count' do
        post :new_user, :user => { :mobile_phone => "3125551212", :zipcode_value => "" }
      end
    end

    assert_response :success
    assert_template :index
    assert assigns(:user).invalid?
  end

  test "should not be able to create a user with a bogus zip code" do
    assert_no_difference 'User.count' do
      assert_no_difference 'Zipcode.count' do
        post :new_user, :user => { :mobile_phone => "3125551212", :zipcode_value => "abc123" }
      end
    end

    assert_response :success
    assert_template :index
    assert assigns(:user).invalid?
  end

  test "should not be able to create a user without a mobile phone" do
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with("60477").returns(GeoKit::GeoLoc.new(:lat => 41.5699614, :lng => -87.7861711))

    assert_no_difference 'User.count' do
      assert_difference 'Zipcode.count', 1 do
        post :new_user, :user => { :mobile_phone => "", :zipcode_value => "60477" }
      end
    end

    assert_response :success
    assert_template :index
    assert assigns(:user).invalid?
  end

  test "should not be able to create a user with a bogus mobile phone" do
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with("60477").returns(GeoKit::GeoLoc.new(:lat => 41.5699614, :lng => -87.7861711))

    assert_no_difference 'User.count' do
      assert_difference 'Zipcode.count', 1 do
        post :new_user, :user => { :mobile_phone => "yaddayadda", :zipcode_value => "60477" }
      end
    end

    assert_response :success
    assert_template :index
    assert assigns(:user).invalid?
  end

end
