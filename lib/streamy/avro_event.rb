require "active_support/core_ext/class/attribute"

module Streamy
  class AvroEvent < Event
    def payload
      avro.encode(payload_attributes.stringify_keys, schema_name: type)
    end

    def payload_attributes
      {
        type: type,
        body: body,
        event_time: event_time
      }
    end
  end
end
