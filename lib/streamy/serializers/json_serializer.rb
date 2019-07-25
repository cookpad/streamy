module Streamy
  module Serializers
    class JsonSerializer
      def self.encode(payload)
        payload.to_json
      end
    end
  end
end
