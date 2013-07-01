require 'test_helper'

class MessageHistoryTest < ActiveSupport::TestCase

  test "should be able to create a message history entry" do
    assert MessageHistory.create!(mobile_phone: '3125551212', message: "This is a test", message_type: "MO")
  end

  test "should not be able to create a message history entry with missing information" do
    assert MessageHistory.new(message: "This is a test", message_type: "MO").invalid?
    assert MessageHistory.new(mobile_phone: '3125551212', message_type: "MO").invalid?
    assert MessageHistory.new(mobile_phone: '3125551212', message: "This is a test").invalid?
  end

  test "should not be able to create a message history with an invalid message type" do
    assert MessageHistory.new(mobile_phone: '3125551212', message: "This is a test", message_type: "XX").invalid?
  end

  test "should be able to find all old messages" do
    assert_equal [message_history(:message_1), message_history(:message_2)], MessageHistory.old
  end

  test "should be able to destroy all old messages" do
    message_1 = message_history(:message_1)
    message_2 = message_history(:message_2)

    assert_difference 'MessageHistory.count', -2 do
      MessageHistory.purge_old_messages
    end

    assert_nil MessageHistory.find_by_id(message_1)
    assert_nil MessageHistory.find_by_id(message_2)
  end

end
