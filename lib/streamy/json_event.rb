module Streamy
  class JsonEvent < Event
    def payload
      payload_attributes.to_json
    end
  end
end
