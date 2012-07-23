class SiteController < ApplicationController

  def index
    @user = User.new
  end

  def new_user
    factory = UserFactory.new
    @user = factory.create_user(params[:user][:mobile_phone], params[:user][:user_location_value])
    @errors = factory.errors

    if @errors.blank?
      service = SmsMessagingService.new
      service.send_message(@user.mobile_phone, OutgoingSmsMessages.signup_prompt)
    else
      render :action => :index
    end
  end

end
