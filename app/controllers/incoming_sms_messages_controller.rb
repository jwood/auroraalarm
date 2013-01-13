class IncomingSmsMessagesController < ApplicationController

  before_filter :validate_request

  def index
    mobile_phone = SignalApi::Phone.sanitize(params['From'])
    message = (params['Body'] && params['Body'].strip)
    IncomingSmsHandler.process(mobile_phone, message)
    render nothing: true
  end

  private

  def validate_request
    validator = Twilio::Util::RequestValidator.new(ENV['TWILIO_AUTH_TOKEN'])
    if !validator.validate(request.original_url, request.request_parameters, request.env['HTTP_X_TWILIO_SIGNATURE'])
      render nothing: true, status: :unauthorized
    end
  end

end
