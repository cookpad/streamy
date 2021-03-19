module Streamy
  module Deserializers
    class AvroDeserializer
      require "avro_turf/messaging"

      DEFAULT_PAYLOAD_FETCHER = ->(params) { params["payload"] }

      def initialize(&payload_fetcher)
        @avro = AvroTurf::Messaging.new(registry_url: Streamy.configuration.avro_schema_registry_url)
        @payload_fetcher = payload_fetcher || DEFAULT_PAYLOAD_FETCHER
      end

      def call(params)
        avro.decode(payload_fetcher.call(params))
      end

      private

        attr_reader :avro, :payload_fetcher
    end
  end
end
