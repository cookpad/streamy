require "avro_turf/messaging"

module Streamy
  module Helpers
    module MessageParser
      def hashify_messages(message_bus_deliveries, encoding_type)
        message_bus_deliveries.map do |message|
          message_hash = message.dup
          message_hash[:payload] = parse_message(message_hash[:payload], encoding_type)
          message_hash
        end
      end

      def parse_message(message_payload, encoding_type)
        if encoding_type == "avro"
          avro.decode(message_payload).deep_symbolize_keys
        else
          JSON.parse(message_payload).deep_symbolize_keys
        end
      end

      def avro
        AvroTurf::Messaging.new(
          registry_url: Streamy.configuration.avro_schema_registry_url,
          schemas_path: Streamy.configuration.avro_schemas_path
        )
      end
    end
  end
end
