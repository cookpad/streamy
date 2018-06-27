module Streamy
  class TypeNotFoundError < StandardError
    def initialize
      super "{ type: ... } key not found on message"
    end
  end
end
