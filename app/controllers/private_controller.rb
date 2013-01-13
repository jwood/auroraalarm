class PrivateController < ApplicationController
  http_basic_authenticate_with name: ENV['PRIVATE_CONTROLLER_USERNAME'], password: ENV['PRIVATE_CONTROLLER_PASSWORD']
end
