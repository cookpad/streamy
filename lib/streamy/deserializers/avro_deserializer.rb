module Streamy
  module Deserializers
    class AvroDeserializer
      require "avro_turf/messaging"

      def initialize
        @avro = AvroTurf::Messaging.new(registry_url: Streamy.configuration.avro_schema_registry_url)
      end

      def call(params)
        avro.decode(params.raw_payload)
      end

      private

        attr_reader :avro
    end
  end
end
