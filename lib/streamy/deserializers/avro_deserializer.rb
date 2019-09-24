require "streamy/avro"
require "avro_turf/messaging"

module Streamy
  module Deserializers
    class AvroDeserializer < Avro
      def call(params)
        parse(params.payload)
      end

      def parse(content)
        messaging.decode(content)
      end
    end
  end
end
