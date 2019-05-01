module Streamy
  class AvroEvent < Event
    def publish
      validate_schema if Rails.env.test?

      super
    end

    def serializer
      Serializers::AvroSerializer.new
    end

    private

      def validate_schema
        serializer.encode(payload)
      end
  end
end
