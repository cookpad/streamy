module Streamy
  class Configuration
    attr_accessor :avro_schema_registry_url, :avro_schemas_path

    def initialize
      @avro_schema_registry_url = nil
      @avro_schemas_path = nil
    end
  end
end
