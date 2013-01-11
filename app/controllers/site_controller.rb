class SiteController < ApplicationController

  def index
    @user = User.new
  end

  def new_user
    respond_to do |format|
      if user_exists?(params[:user][:mobile_phone])
        @message = "You have already signed up. To confirm your signup, or change your zipcode, text AURORA followed by your zipcode (AURORA 90210) to 312-386-5114."
        format.html { render :index }
        format.js
      else
        @user, @errors = create_new_user
        if @errors.blank?
          send_sms_signup_prompt
          @message = "Thank you for signing up! You will soon receive a text message asking you to confirm your subscription by replying 'Y'."

          format.html { render :index }
          format.js
        else
          format.html { render :index }
          format.js { render :signup_error }
        end
      end
    end
  end

  private

  def user_exists?(mobile_phone)
    User.find_by_mobile_phone(SignalApi::Phone.sanitize(mobile_phone))
  end

  def create_new_user
    factory = UserFactory.new
    user = factory.create_user(params[:user][:mobile_phone], params[:user][:user_location_value])
    errors = factory.errors
    [user, errors]
  end

  def send_sms_signup_prompt
    service = Services::SmsMessagingService.new
    service.send_message(@user.mobile_phone, OutgoingSmsMessages.signup_prompt)
  end

end
