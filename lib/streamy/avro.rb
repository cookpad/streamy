module Streamy
  class Avro
    def self.messaging
      @_messaging ||= connect_avro
    end

    def self.connect_avro
      AvroTurf::Messaging.new(
        registry_url: Streamy.configuration.avro_schema_registry_url,
        schemas_path: Streamy.configuration.avro_schemas_path,
        logger: ::Streamy.logger
      )
    end
  end
end
