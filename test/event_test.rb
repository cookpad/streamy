require "test_helper"

module Streamy
  class EventTest < Minitest::Test
    class ValidEvent < Event
      def topic; end
      def body; end
      def event_time; end
    end

    class ValidEventWithParams < Event
      def initialize(i)
        @i = i
      end

      def body
        {
          i: @i
        }
      end

      def event_time
        -"now"
      end

      def topic
        -"valid_event_with_params_topic"
      end
    end

    class OveriddenPriority < ValidEvent
      priority :low
    end

    class EventWithoutTopic < Event
      def event_time; end
      def body; end
    end

    class EventWithoutEventTime < Event
      def topic; end
      def body; end
    end

    class EventWithoutBody < Event
      def topic; end
      def event_time; end
    end

    def test_helpful_error_message_on_missing_topic
      assert_runtime_error "topic must be implemented on Streamy::EventTest::EventWithoutTopic" do
        EventWithoutTopic.publish
      end
    end

    def test_helpful_error_message_on_missing_event_time
      assert_runtime_error "event_time must be implemented on Streamy::EventTest::EventWithoutEventTime" do
        EventWithoutEventTime.publish
      end
    end

    def test_helpful_error_message_on_missing_body
      assert_runtime_error "body must be implemented on Streamy::EventTest::EventWithoutBody" do
        EventWithoutBody.publish
      end
    end

    def test_default_priority
      ValidEvent.publish

      assert_published_event(priority: :standard)
    end

    def test_overidden_priority
      OveriddenPriority.publish

      assert_published_event(priority: :low)
    end

    def test_deliver_batched_events_in_block
      Streamy.message_bus = Streamy::MessageBuses::TestMessageBus.new

      ValidEventWithParams.deliver do |event|
        2.times do |i|
          event.publish(i)
        end
        assert_empty(Streamy.message_bus.deliveries)
      end

      assert_published_event(
        topic: "valid_event_with_params_topic",
        payload: {
            type: "valid_event_with_params", 
            body: { i: 0 }, 
            event_time: "now"
          }
      )
      assert_published_event(
        topic: "valid_event_with_params_topic",
        payload: {
            type: "valid_event_with_params", 
            body: { i: 1 }, 
            event_time: "now"
          }
      )
    end
  end
end
