require "test_helper"

module Streamy
  class EventTest < Minitest::Test
    class ValidEvent < Event
      def topic; end
      def body; end
      def event_time; end
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

    def test_wrapping_message_bus_errors
      Streamy.message_bus.stubs(:deliver).raises("ConnectionError")

      error = assert_raises(PublicationFailedError) do
        ValidEvent.publish
      end

      assert_match(/ConnectionError/, error.message)
    end
  end
end
