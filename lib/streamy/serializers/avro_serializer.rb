module Streamy
  module Serializers
    class AvroSerializer
      require "avro_patches"
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

      def self.encode(payload)
        messaging.encode(payload.deep_stringify_keys, schema_name: payload[:type])
      end
    end
  end
end
