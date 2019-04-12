# Avro
# require patches for avro to allow for logical types in schemas
require "avro_patches"
require "avro_turf/messaging"

module Streamy
  class AvroEvent < Event
    def payload
      avro.encode(payload_attributes.deep_stringify_keys, schema_name: type)
    end

    private

      def avro
        AvroTurf::Messaging.new(
          registry_url: Streamy.configuration.avro_schema_registry_url,
          schemas_path: Streamy.configuration.avro_schemas_path
        )
      end
  end
end
