module Streamy
  module Serializers
    class AvroSerializer
      def encode(payload_attributes)
        Streamy.avro_messaging.encode(payload_attributes.deep_stringify_keys, schema_name: payload_attributes[:type])
      end
    end
  end
end
