require "test_helper"

class DummyConsumer
  include Streamy::Consumer
end

module EventHandlers
  class DummyEvent < Streamy::EventHandler
    cattr_accessor :times_called do
      0
    end

    def process
      self.times_called += 1
    end
  end
end

module Streamy
  class ConsumerTest < Minitest::Test
    def test_processing_empty_message
      message = {}
      assert_raises(TypeNotFoundError) do
        DummyConsumer.new.process(message)
      end
    end

    def test_ignoring_duplicate_messages
      message = { key: "1234", type: "dummy_event" }

      DummyConsumer.new.process(message)
      DummyConsumer.new.process(message)

      assert_equal 1, EventHandlers::DummyEvent.times_called
    end
  end
end
