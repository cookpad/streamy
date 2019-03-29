require "test_helper"
require "avro_turf/test/fake_confluent_schema_registry_server"
require "webmock/minitest"

module Streamy
  class AvroEventTest < Minitest::Test
    def setup
      Streamy.configuration.avro_schema_registry_url = "http://registry.example.com"
      Streamy.configuration.avro_schemas_path = "test/support/schemas"
      FakeConfluentSchemaRegistryServer.clear
      stub_request(:any, /^#{Streamy.configuration.avro_schema_registry_url}/).to_rack(FakeConfluentSchemaRegistryServer)
    end

    class EventWithoutTopic < AvroEvent
      def event_time; end
      def body; end
    end

    class EventWithoutEventTime < AvroEvent
      def topic; end
      def body; end
    end

    class EventWithoutBody < AvroEvent
      def topic; end
      def event_time; end
    end

    class IncorrectAttributeEvent < AvroEvent
      def topic
        :bacon
      end

      def body
        {
          smoked: "true",
          streaky: 100
        }
      end

      def event_time
        "nowish"
      end
    end

    class TestEvent < AvroEvent
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

    class EventWithNoSchema < AvroEvent
      def topic; end
      def body; end
      def event_time; end
    end

    def test_helpful_error_message_on_missing_topic
      assert_runtime_error "topic must be implemented on Streamy::AvroEventTest::EventWithoutTopic" do
        EventWithoutTopic.publish
      end
    end

    def test_helpful_error_message_on_missing_event_time
      assert_runtime_error "event_time must be implemented on Streamy::AvroEventTest::EventWithoutEventTime" do
        EventWithoutEventTime.publish
      end
    end

    def test_helpful_error_message_on_missing_body
      assert_runtime_error "body must be implemented on Streamy::AvroEventTest::EventWithoutBody" do
        EventWithoutBody.publish
      end
    end

    def test_helpful_error_message_on_incorrect_attribute_type
      assert_raises Avro::IO::AvroTypeError do
        IncorrectAttributeEvent.publish
      end
    end

    def test_helpful_error_message_on_event_with_no_schema
      assert_raises AvroTurf::SchemaNotFoundError do
        EventWithNoSchema.publish
      end
    end

    def test_publish
      SecureRandom.stubs(:uuid).returns("IAMUUID")

      TestEvent.publish

      assert_published_event(
        key: "IAMUUID",
        topic: :bacon,
        payload: "\u0000\u0000\u0000\u0000\u0000\u0014test_event\u0002\fnowish\u0002\btrue\u0002\nfalse"
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
  end
end
