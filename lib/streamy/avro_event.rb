module Streamy
  class AvroEvent < Event
    require "streamy/serializers/avro_serializer"

    def serializer
      Serializers::AvroSerializer.new
    end
  end
end
