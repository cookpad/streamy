module Streamy
  module Deserializers
    class AvroDeserializer
      require "avro_turf/messaging"

      attr_reader :avro

      def initialize
        @avro = AvroTurf::Messaging.new(registry_url: Streamy.configuration.avro_schema_registry_url)
      end

      def call(params)
        avro.decode(params.payload)
      end
    end
  end
end
