module Streamy
  class AvroEvent < Event
    def payload
      Streamy.avro_messaging.encode(payload_attributes.deep_stringify_keys, schema_name: type)
    end
  end
end
