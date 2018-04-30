require "test_helper"

module Streamy
  class EventTest < Minitest::Test
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

    private

      def assert_runtime_error(message, &block)
        error = assert_raises RuntimeError do
          yield
        end

        assert_equal message, error.message
      end
  end
end
