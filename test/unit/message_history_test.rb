require 'test_helper'

class MessageHistoryTest < ActiveSupport::TestCase

  test "should be able to create a message history entry" do
    assert MessageHistory.create!(:mobile_phone => '3125551212', :message => "This is a test", :message_type => "MO")
  end

  test "should not be able to create a message history entry with missing information" do
    assert MessageHistory.new(:message => "This is a test", :message_type => "MO").invalid?
    assert MessageHistory.new(:mobile_phone => '3125551212', :message_type => "MO").invalid?
    assert MessageHistory.new(:mobile_phone => '3125551212', :message => "This is a test").invalid?
  end

  test "should not be able to create a message history with an invalid message type" do
    assert MessageHistory.new(:mobile_phone => '3125551212', :message => "This is a test", :message_type => "XX").invalid?
  end

end
