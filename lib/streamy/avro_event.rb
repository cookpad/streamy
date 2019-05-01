module Streamy
  class AvroEvent < Event
    def publish
      validate_schema if test_environment?

      super
    end

    def serializer
      Serializers::AvroSerializer.new
    end

    private

      def test_environment?
        ENV["RAILS_ENV"] == "test" || ::Rails.env.test?
      end

      def validate_schema
        serializer.encode(payload)
      end
  end
end
