require "test_helper"

module Streamy
  class MessageProcessorTest < Minitest::Test
    def test_processing_empty_message
      message = Message.new({})
      assert_raises(TypeNotFoundError) do
        MessageProcessor.process(message)
      end
    end
  end
end
