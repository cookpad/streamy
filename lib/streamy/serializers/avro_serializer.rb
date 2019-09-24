require "streamy/avro"
require "avro_turf/messaging"

module Streamy
  module Serializers
    class AvroSerializer < Avro
      def self.encode(payload)
        messaging.encode(payload.deep_stringify_keys, schema_name: payload[:type])
      end
    end
  end
end
