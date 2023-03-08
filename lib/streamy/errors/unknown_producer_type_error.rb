module Streamy
  class UnknownProducerTypeError < StandardError
    def initialize(producer_type)
      super "Unknown producer type #{producer_type}"
    end
  end
end
