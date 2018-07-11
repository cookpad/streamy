require "test_helper"
require "active_support/cache/memory_store"

class DummyConsumer
  include Streamy::Consumer
end

module EventHandlers
  class DummyEvent < Streamy::EventHandler
    cattr_accessor :times_called

    def process
      self.times_called += 1
    end
  end
end

module Streamy
  class ConsumerTest < Minitest::Test
    def setup
      EventHandlers::DummyEvent.times_called = 0
    end

    def test_processing_empty_message
      message = {}

      assert_raises(TypeNotFoundError) do
        DummyConsumer.new.process(message)
      end
    end

    def test_ignoring_duplicate_messages_if_cache_is_on
      Streamy.cache = ActiveSupport::Cache::MemoryStore.new
      message = { key: "1234", type: "dummy_event" }

      DummyConsumer.new.process(message)
      DummyConsumer.new.process(message)

      assert_equal 1, EventHandlers::DummyEvent.times_called
    end

    def test_allowing_duplicate_messages_if_cache_is_off
      Streamy.cache = nil
      message = { key: "1234", type: "dummy_event" }

      DummyConsumer.new.process(message)
      DummyConsumer.new.process(message)

      assert_equal 2, EventHandlers::DummyEvent.times_called
    end
  end
end
