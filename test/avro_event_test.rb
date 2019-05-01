require "test_helper"
require "avro_turf/test/fake_confluent_schema_registry_server"
require "webmock/minitest"

module Streamy
  class AvroEventTest < Minitest::Test
    def setup
      Streamy.configuration.avro_schema_registry_url = "http://registry.example.com"
      Streamy.configuration.avro_schemas_path = "test/fixtures/schemas"
      FakeConfluentSchemaRegistryServer.clear
      stub_request(:any, /^#{Streamy.configuration.avro_schema_registry_url}/).to_rack(FakeConfluentSchemaRegistryServer)
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

    class EventWithNoSchema < AvroEvent
      def topic; end
      def body; end
      def event_time; end
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
  end
end
