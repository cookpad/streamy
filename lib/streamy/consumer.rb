require "hutch"

module Streamy
  module Consumer
    def self.included(base)
      base.include Hutch::Consumer
      base.consume "#{Streamy::DEFAULT_TOPIC_PREFIX}.#"
    end

    def process(message)
      MessageProcessor.new(message).run
    end
  end
end
