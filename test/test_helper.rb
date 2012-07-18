ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  set_callback :setup, :before, :clear_cache
  set_callback :setup, :before, :disable_web_access

  # Add more helper methods to be used by all tests here...
  def clear_cache
    Rails.cache.clear
  end

  def disable_web_access
    FakeWeb.allow_net_connect = false
    FakeWeb.clean_registry
  end
end
