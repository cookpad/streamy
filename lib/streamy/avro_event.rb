module Streamy
  class AvroEvent < Event
    require "streamy/serializers/avro_serializer"

    def encoded_payload
      Serializers::AvroSerializer.encode(payload, schema_namespace: schema_namespace)
    end


    private
      def schema_namespace; end
  end
end
