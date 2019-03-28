module Streamy
  class Configuration
    attr_accessor :registry_url, :schemas_path

    def initialize
      @registry_url = nil
      @schemas_path = nil
    end
  end
end
