module Streamy
  class JsonEvent < Event
    def serializer
      Serializers::JsonSerializer.new
    end
  end
end
