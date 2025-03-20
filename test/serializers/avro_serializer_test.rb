require "test_helper"
require_relative "../support/authorized_fake_confluent_schema_registry_server"
require "webmock/minitest"
require "avro"

module Streamy
  module Serializers
    class AvroSerializerTest < Minitest::Test
      def setup
        Streamy.configuration.avro_schema_registry_url = "http://registry.example.com"
        Streamy.configuration.avro_schemas_path = "test/fixtures/schemas"
        AvroSerializer.clear_messaging_cache
        stub_request(:any, /^#{Streamy.configuration.avro_schema_registry_url}/).to_rack(AuthorizedFakeConfluentSchemaRegistryServer)
        AuthorizedFakeConfluentSchemaRegistryServer.clear
      end

      def test_encode_successful
        payload = {
          type: "test_event",
          event_time: "nowish",
          body: {
            smoked: "true",
            streaky: "false"
          }
        }

        result = AvroSerializer.encode(payload)
        assert result, "Should return encoded data"
      end

      def test_retry_behavior_and_error_after_retries
        payload = {
          type: "test_event",
          event_time: "nowish",
          body: {
            smoked: "true",
            streaky: "false"
          }
        }

        # Mock the messaging object to raise a validation error
        messaging_mock = mock
        schema = nil
        schema_id = 1

        AvroSerializer.stubs(:messaging).returns(messaging_mock)
        messaging_mock.expects(:register_schema).times(3).returns([schema, schema_id])
        messaging_mock.expects(:encode).times(3).raises(Avro::SchemaValidator::ValidationError.new("Test validation error"))
        AvroSerializer.expects(:clear_messaging_cache).times(3)

        error = assert_raises(Avro::SchemaValidator::ValidationError) do
          AvroSerializer.encode(payload)
        end

        assert_equal "Test validation error", error.message
      end
    end
  end
end
