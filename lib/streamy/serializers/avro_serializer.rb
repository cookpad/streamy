module Streamy
  module Serializers
    class AvroSerializer
      require "avro_turf/messaging"

      RETRY_COUNT = 3

      def self.messaging
        @_messaging ||= connect_avro
      end

      def self.connect_avro
        AvroTurf::Messaging.new(
          registry_url: Streamy.configuration.avro_schema_registry_url,
          schemas_path: Streamy.configuration.avro_schemas_path,
          logger: ::Streamy.logger
        )
      end

      def self.clear_messaging_cache
        @_messaging = connect_avro
      end

      def self.encode(payload, schema_namespace: nil)
        RETRY_COUNT.times do |i|
          # Workaround for invalid message error
          # https://github.com/cookpad/engineering/issues/2442
          # https://github.com/cookpad/engineering/issues/1731
          schema, schema_id = messaging.register_schema(subject: nil, schema_name: payload[:type], namespace: schema_namespace)
          begin
            return messaging.encode(payload.deep_stringify_keys, schema_id: schema_id, namespace: schema_namespace, validate: true)
          rescue Avro::SchemaValidator::ValidationError => e
            # Either schema_id or schema retrieved using passed schema_id in encode method is not valid
            ::Streamy.logger.error("Avro schema validation error: #{e.message}. Retrying...")
            clear_messaging_cache
            raise e if i == RETRY_COUNT - 1
          end
        end
      end
    end
  end
end
