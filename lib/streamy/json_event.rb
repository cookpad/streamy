module Streamy
  class JsonEvent < Event
    def payload
      payload_attributes.to_json
    end

    def encoding_format
      "json".freeze
    end
  end
end
