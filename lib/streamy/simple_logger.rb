module Streamy
  class SimpleLogger < SimpleDelegator
    def initialize(output = STDOUT)
      logger = Logger.new(output)
      logger.formatter = ->(_, datetime, _, msg) { "#{datetime.to_s(:db)} - #{msg}\n" }
      __setobj__(logger)
    end
  end
end
