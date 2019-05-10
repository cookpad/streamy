module Streamy
  class AvroEvent < Event
    require "streamy/serializers/avro_serializer"

    def encoded_payload
      Serializers::AvroSerializer.encode(payload)
    end
  end
end
