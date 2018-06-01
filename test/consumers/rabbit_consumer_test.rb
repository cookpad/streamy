require "test_helper"
require "active_support/cache/memory_store"

class DummyConsumer
  include Streamy::Consumers::RabbitConsumer
end

class FilteringDummyConsumer
  include Streamy::Consumers::RabbitConsumer
  start_from 1525058571
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
  module Consumers
    class RabbitConsumerTest < Minitest::Test
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

      def test_ignoring_messages_from_before_start_from
        message = { key: "1234", event_time: "2018-04-30 03:22:50 UTC", type: "dummy_event" }

        FilteringDummyConsumer.new.process(message)

        assert_equal 0, EventHandlers::DummyEvent.times_called
      end
    end
  end
end
