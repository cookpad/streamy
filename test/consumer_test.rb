require "test_helper"

module Streamy
  class ConsumerTest < Minitest::Test
    class DummyConsumer
      include Consumer
    end

    def test_processing_empty_message
      message = {}
      assert_raises(TypeNotFoundError) do
        DummyConsumer.new.process(message)
      end
    end
  end
end
