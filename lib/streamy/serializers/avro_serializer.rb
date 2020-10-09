module Streamy
  module Serializers
    class AvroSerializer
      require "avro_turf/messaging"

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

      def self.encode(payload, schema_name: nil, schema_namespace: nil)
        messaging.encode(payload.deep_stringify_keys, schema_name: schema_name || payload[:type], namespace: schema_namespace)
      end
    end
  end
end
