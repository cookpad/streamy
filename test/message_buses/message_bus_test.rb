require "test_helper"

module Streamy
  class MessageBusTest < Minitest::Test
    class DummyMessageBus < MessageBuses::MessageBus
      def deliver(key:, topic:, type:, body:, event_time:)
        raise "ConnectionError"
      end
    end

    def test_safe_deliver_wrapping_errors
      bus = DummyMessageBus.new

      error = assert_raises(PublicationFailedError) do
        bus.safe_deliver(key: "key", topic: "topic", type: "type", body: "body", event_time: Time.now.utc)
      end

      assert_match(/ConnectionError/, error.message)
    end
  end
end
