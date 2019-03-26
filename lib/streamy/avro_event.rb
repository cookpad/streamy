require "active_support/core_ext/class/attribute"
require "avro_turf/messaging"

module Streamy
  class AvroEvent < Event
    def payload
      avro.encode(payload_attributes.deep_stringify_keys, schema_name: type)
    end

    def payload_attributes
      {
        type: type,
        body: body,
        event_time: event_time
      }
    end

    private

      def avro
        AvroTurf::Messaging.new(registry_url: ENV["SCHEMA_REGISTRY_URL"], schemas_path: ENV["SCHEMAS_PATH"])
      end
  end
end
