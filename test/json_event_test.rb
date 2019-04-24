require "test_helper"

module Streamy
  class JsonEventTest < Minitest::Test
    def teardown
      Streamy.message_bus.deliveries.clear
    end

    class TestEvent < JsonEvent
      def topic
        :bacon
      end

      def body
        {
          smoked: "true",
          streaky: "false"
        }
      end

      def event_time
        "nowish"
      end
    end

    class OveriddenPriority < TestEvent
      priority :low
    end

    class ValidEventWithParams < TestEvent
      def initialize(event_number)
        @event_number = event_number
      end

      def topic
        -"valid_event_with_params_topic"
      end

      def body
        {
          event_number: @event_number
        }
      end

      def event_time
        -"now"
      end
    end

    def test_publish
      SecureRandom.stubs(:uuid).returns("IAMUUID")

      TestEvent.publish

      assert_published_event(
        key: "IAMUUID",
        topic: :bacon,
        payload: {
          type: "test_event",
          body: { smoked: "true", streaky: "false" },
          event_time: "nowish"
        }
      )
    end

    def test_default_priority
      TestEvent.publish

      assert_published_event(priority: :standard)
    end

    def test_overidden_priority
      OveriddenPriority.publish

      assert_published_event(priority: :low)
    end

    def test_deliver_batched_events_in_block
      ValidEventWithParams.deliver do |event|
        2.times do |i|
          event.publish(i)
        end
      end

      assert_published_event(
        topic: "valid_event_with_params_topic",
        payload: {
          type: "valid_event_with_params",
          body: { event_number: 0 },
          event_time: "now"
        }
      )
      assert_published_event(
        topic: "valid_event_with_params_topic",
        payload: {
          type: "valid_event_with_params",
          body: { event_number: 1 },
          event_time: "now"
        }
      )
    end
  end
end
