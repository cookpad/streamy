module Streamy
  module Serializers
    class JsonSerializer
      def encode(payload)
        payload.to_json
      end
    end
  end
end
