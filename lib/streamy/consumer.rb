require "hutch"

module Streamy
  module Consumer
    def self.included(base)
      base.include Hutch::Consumer
      Hutch::Logging.logger = Streamy.logger
      base.consume "#{Streamy::DEFAULT_TOPIC_PREFIX}.#"
    end

    def process(message)
      MessageProcessor.new(message).run
    end
  end
end
