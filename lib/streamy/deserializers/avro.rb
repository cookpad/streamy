module Streamy
  module Deserializers
    class Avro
      def self.registry_url=(registry_url)
        @registry_url = registry_url
      end

      def self.from_registry(schema_name = nil)
        raise ArgumentError, "You have to specify the registry path first" if @registry_url.nil?

        AvroDeserializer.new(AvroTurf::Messaging.new(registry_url: @registry_url), schema_name)
      end
    end
  end
end
