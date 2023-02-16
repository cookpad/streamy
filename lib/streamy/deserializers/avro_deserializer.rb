module Streamy
  module Deserializers
    class AvroDeserializer
      require "avro_turf/messaging"

      def call(params)
        avro.decode(params.raw_payload)
      end

      private

        def avro
          @_avro ||= AvroTurf::Messaging.new(registry_url: Streamy.configuration.avro_schema_registry_url)
        end
    end
  end
end
