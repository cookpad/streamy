module Streamy
  class UnknownPriorityError < StandardError
    def initialize(priority)
      super "Unknown priority #{priority}"
    end
  end
end
