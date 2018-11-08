require "test_helper"
require "active_support/cache/memory_store"

class DummyConsumer
  include Streamy::Consumer
end

class DummyEventHandler < Streamy::EventHandler
  cattr_accessor :times_called

  def process
    self.times_called += 1
  end
end

module Streamy
  class ConsumerTest < Minitest::Test
    def setup
      DummyEventHandler.times_called = 0
    end

    def test_processing_empty_message
      message = {}

      assert_raises(TypeNotFoundError) do
        DummyConsumer.new.process(message)
      end
    end

    def test_processing_message_twices
      Streamy.cache = nil
      message = { key: "1234", type: "dummy_event" }

      DummyConsumer.new.process(message)
      DummyConsumer.new.process(message)

      assert_equal 2, DummyEventHandler.times_called
    end
  end
end
