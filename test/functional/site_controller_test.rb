require 'test_helper'

class SiteControllerTest < ActionController::TestCase

  test "should be able to fetch the index page" do
    get :index
    assert_response :success
    assert_template :index
    assert_not_nil assigns(:user)
  end

  test "should be able to create a new user" do
    expects_valid_location("60477")
    SmsMessagingService.any_instance.expects(:send_message).with("3125551212", OutgoingSmsMessages.signup_prompt)

    assert_difference 'User.count', 1 do
      assert_difference 'UserLocation.count', 1 do
        post :new_user, :user => { :mobile_phone => "3125551212", :user_location_value => "60477" }
      end
    end

    assert_response :success
    assert_template :new_user

    user = User.last
    assert_equal "3125551212", user.mobile_phone

    user_location = UserLocation.last
    assert_equal user, user_location.user
    assert_equal "60477", user_location.postal_code
    assert_equal 41.5699614, user_location.latitude
    assert_equal -87.7861711, user_location.longitude
    assert_equal 52, user_location.magnetic_latitude
  end

  test "should not be able to create a user without a zip code" do
    assert_no_difference 'User.count' do
      assert_no_difference 'UserLocation.count' do
        post :new_user, :user => { :mobile_phone => "3125551212", :user_location_value => "" }
      end
    end

    assert_response :success
    assert_template :index
    assert !assigns(:errors).blank?
  end

  test "should not be able to create a user with a bogus zip code" do
    expects_invalid_location("abc123")

    assert_no_difference 'User.count' do
      assert_no_difference 'UserLocation.count' do
        post :new_user, :user => { :mobile_phone => "3125551212", :user_location_value => "abc123" }
      end
    end

    assert_response :success
    assert_template :index
    assert !assigns(:errors).blank?
  end

  test "should not be able to create a user without a mobile phone" do
    expects_valid_location("60477")

    assert_no_difference 'User.count' do
      assert_no_difference 'UserLocation.count' do
        post :new_user, :user => { :mobile_phone => "", :user_location_value => "60477" }
      end
    end

    assert_response :success
    assert_template :index
    assert !assigns(:errors).blank?
  end

  test "should not be able to create a user with a bogus mobile phone" do
    expects_valid_location("60477")

    assert_no_difference 'User.count' do
      assert_no_difference 'UserLocation.count' do
        post :new_user, :user => { :mobile_phone => "yaddayadda", :user_location_value => "60477" }
      end
    end

    assert_response :success
    assert_template :index
    assert !assigns(:errors).blank?
  end

end
