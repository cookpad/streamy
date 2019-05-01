module Streamy
  module Serializers
    class JsonSerializer
      def encode(payload_attributes)
        payload_attributes.to_json
      end
    end
  end
end
