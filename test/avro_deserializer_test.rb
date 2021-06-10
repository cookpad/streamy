require "test_helper"
require "avro_turf/test/fake_confluent_schema_registry_server"
require "webmock/minitest"

module Streamy
  class AvroDeserializerTest < Minitest::Test
    def setup
      Streamy.configuration.avro_schema_registry_url = "http://registry.example.com"
      Streamy.configuration.avro_schemas_path = "test/fixtures/schemas"
      Serializers::AvroSerializer.clear_messaging_cache
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

      def to_encoded_params
        OpenStruct.new(raw_payload: encoded_payload)
      end
    end

    def test_deserialized_message
      message = TestEvent.new.to_encoded_params
      result = Deserializers::AvroDeserializer.new.call(message)

      assert_equal(
        {
          "type" => "test_event",
          "event_time" => "nowish",
          "body" => {
            "smoked" => "true",
            "streaky" => "false"
          }
        }, result
      )
    end
  end
end
