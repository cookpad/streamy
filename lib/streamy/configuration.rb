module Streamy
  class Configuration
    attr_accessor :avro_schema_registry_url, :avro_schemas_path, :producer_batched_message_limit

    def initialize
      @avro_schema_registry_url = nil
      @avro_schemas_path = nil
      @producer_batched_message_limit = 1000
    end
  end
end
