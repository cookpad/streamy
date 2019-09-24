module Streamy
  module Deserializers
    class AvroDeserializer
      require "avro_turf/messaging"

      attr_reader :avro, :schema_name

      def initialize(avro, schema_name)
        @avro = avro
        @schema_name = schema_name
      end

      def call(params)
        parse(params.payload)
      end

      def parse(content)
        avro.decode(content, schema_name: schema_name)
      end
    end
  end
end
