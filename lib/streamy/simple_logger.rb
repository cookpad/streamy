module Streamy
  class SimpleLogger < SimpleDelegator
    def initialize(output = STDOUT)
      logger = Logger.new(output)
      logger.formatter =
        if Time.new.respond_to?(:to_fs)
          # ActiveSupport 7.0 deprecates Time#to_s(format) and introduced Time#to_fs(format).
          # ActiveSupport 7.1 removed Time#to_s(format).
          ->(_, datetime, _, msg) { "#{datetime.to_fs(:db)} - #{msg}\n" }
        else
          ->(_, datetime, _, msg) { "#{datetime.to_s(:db)} - #{msg}\n" }
        end
      __setobj__(logger)
    end
  end
end
