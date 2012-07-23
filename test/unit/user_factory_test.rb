require 'test_helper'

class UserFactoryTest < ActiveSupport::TestCase

  def setup
    @factory = UserFactory.new
  end

  test "should be able to create a new user with location data" do
    expects_valid_location("60477")

    user = nil
    assert_difference 'User.count', 1 do
      assert_difference 'UserLocation.count', 1 do
        user = @factory.create_user('3125551212', '60477')
      end
    end

    assert @factory.errors.empty?
    assert user.persisted?

    assert_equal '3125551212', user.mobile_phone
    assert_equal 'Tinley Park', user.user_location.city
    assert_equal 'IL', user.user_location.state
    assert_equal '60477', user.user_location.postal_code
    assert_equal 'US', user.user_location.country
    assert_equal 41.5699614, user.user_location.latitude
    assert_equal -87.7861711, user.user_location.longitude
    assert_equal 52, user.user_location.magnetic_latitude
  end

  test "should not create the user if the mobile phone is invalid" do
    expects_valid_location("60477")

    assert_no_difference 'User.count' do
      assert_no_difference 'UserLocation.count' do
        user = @factory.create_user('foobar', '60477')
        assert !user.persisted?
      end
    end

    assert_equal ["Mobile phone is invalid"], @factory.errors
  end

  test "should not create the user if the mobile phone is in use" do
    expects_valid_location("60477")

    assert_no_difference 'User.count' do
      assert_no_difference 'UserLocation.count' do
        user = @factory.create_user(users(:john).mobile_phone, '60477')
        assert !user.persisted?
      end
    end

    assert_equal ["A user with the specified mobile phone already exists"], @factory.errors
  end

  test "should not create a new user of the location provided is invalid" do
    expects_invalid_location("zzz")

    assert_no_difference 'User.count' do
      assert_no_difference 'UserLocation.count' do
        user = @factory.create_user('3125551212', 'zzz')
        assert !user.persisted?
      end
    end

    assert_equal ["Location is invalid"], @factory.errors
  end

end
