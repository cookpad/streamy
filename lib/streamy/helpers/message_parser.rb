require "avro_turf/messaging"

module Streamy
  module Helpers
    module MessageParser
      def hashify_messages(message_bus_deliveries)
        message_bus_deliveries.map do |message|
          message_hash = message.dup
          message_hash[:payload] = parse_message(message_hash[:payload])
          message_hash
        end
      end

      def parse_message(message_payload)
        JSON.parse(message_payload).deep_symbolize_keys
      rescue JSON::ParserError
        avro.decode(message_payload).deep_symbolize_keys
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
