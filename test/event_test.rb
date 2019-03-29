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

    class TestEvent < Event
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

    def test_publish
      SecureRandom.stubs(:uuid).returns("IAMUUID")

      TestEvent.new.publish

      assert_published_event(
        key: "IAMUUID",
        topic: :bacon,
        type: "test_event",
        body: { smoked: "true", streaky: "false" },
        event_time: "nowish"
      )
    end

    def test_default_priority
      TestEvent.new.publish

      assert_published_event(priority: :standard)
    end

    def test_overidden_priority
      OveriddenPriority.new.publish

      assert_published_event(priority: :low)
    end
  end
end
