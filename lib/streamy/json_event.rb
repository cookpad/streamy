module Streamy
  class JsonEvent < Event
    require "streamy/serializers/json_serializer"

    def encoded_payload
      Serializers::JsonSerializer.encode(payload)
    end
  end
end
