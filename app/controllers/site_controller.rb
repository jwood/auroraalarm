class SiteController < ApplicationController

  def index
    @user = User.new
  end

  def new_user
    zipcode = Zipcode.find_or_create_with_geolocation_data(params[:user][:zipcode_value])
    @user = User.new(params[:user].merge(:zipcode => zipcode))

    if @user.save
      service = SmsMessagingService.new
      service.send_message(@user.mobile_phone, OutgoingSmsMessages.signup_prompt)
    else
      render :action => :index
    end
  end

end
