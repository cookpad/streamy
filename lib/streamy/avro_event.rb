module Streamy
  class AvroEvent < Event
    def serializer
      Serializers::AvroSerializer.new
    end
  end
end
