module Streamy
  class JsonEvent < Event
    require "streamy/serializers/json_serializer"

    def serializer
      Serializers::JsonSerializer.new
    end
  end
end
