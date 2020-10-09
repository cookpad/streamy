module Streamy
  class AvroEvent < Event
    require "streamy/serializers/avro_serializer"

    def encoded_payload
      Serializers::AvroSerializer.encode(payload, schema_name: schema_name, schema_namespace: schema_namespace)
    end


    private
      def schema_namespace; end
      def schema_name; end
  end
end
